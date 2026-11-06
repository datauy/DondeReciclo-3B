require 'test_helper'

class ClusteredContainersTest < ActionDispatch::IntegrationTest
  self.fixture_table_names = []

  setup do
    @country = Country.create!(name: 'Test country')
    @program = Program.create!(name: 'Test program', country: @country)
    dimension = Dimension.create!(name: 'Test dimension')
    @material = Material.create!(name: 'Paper', dimension_id: dimension.id)
    @other_material = Material.create!(name: 'Glass', dimension_id: dimension.id)
    @waste = Waste.create!(name: 'Paper waste', material: @material)
    @other_waste = Waste.create!(name: 'Glass waste', material: @other_material)
    @sub_program = SubProgram.create!(program: @program, material: @material)
    @sub_program.materials << [@material, @other_material]
    @sub_program.wastes << [@waste, @other_waste]
    @other_sub_program = SubProgram.create!(program: @program, material: @other_material)
    @other_sub_program.materials << @other_material
    @other_sub_program.wastes << @other_waste
    @type = ContainerType.create!
    @bounds = { sw: '0,0', ne: '4,4' }
  end

  test 'missing and false flags preserve the existing pins for both endpoints and versions' do
    container(1, 1)
    container(1.01, 1.01)
    [nil, '1.3', '2'].each do |version|
      ['containers_bbox', 'containers_bbox4materials'].each do |endpoint|
        filters = endpoint.end_with?('materials') ? { materials: @material.id.to_s } : {}
        original = search(endpoint, filters.merge(version: version))
        assert_equal 2, original.length
        assert original.all? { |pin| pin.key?('id') && !pin.key?('cluster') }
        assert_equal original, search(endpoint, filters.merge(version: version, clustered: 'false'))
      end
    end
  end

  test 'clusters and singletons retain all matching containers exactly once' do
    first = container(1.01, 1.01)
    second = container(1.02, 1.02)
    isolated = container(3, 3)
    container(1.03, 1.03, hidden: true)
    container(1.04, 1.04, public_site: false)
    container(5, 5)

    ['2', '2.1'].each do |version|
      result = search('containers_bbox', version: version, clustered: 'true')
      cluster = result.find { |item| item['cluster'] }
      pin = result.find { |item| item['id'] == isolated.id }
      assert_equal 2, result.length
      assert_equal %w[cluster count ids latitude longitude], cluster.keys.sort
      assert_equal [first.id, second.id], cluster['ids']
      assert_equal 2, cluster['count']
      assert_equal 1.01, cluster['latitude']
      assert_equal 1.01, cluster['longitude']
      assert_equal search('containers_bbox', version: version).find { |item| item['id'] == isolated.id }, pin
    end
  end

  test 'v1 ignores the clustered flag for both endpoints' do
    container(1.01, 1.01)
    container(1.02, 1.02)
    [nil, '1', '1.3'].each do |version|
      ['containers_bbox', 'containers_bbox4materials'].each do |endpoint|
        filters = endpoint.end_with?('materials') ? { materials: @material.id.to_s } : {}
        original = search(endpoint, filters.merge(version: version))
        assert_equal 2, original.length
        assert_equal original, search(endpoint, filters.merge(version: version, clustered: 'true'))
        assert_equal original, search(endpoint, filters.merge(version: version, clustered: 'invalid'))
      end
    end
  end

  test 'filters deduplicate joins and retain every id beyond 100 and the v2 dimensions limit' do
    members = 105.times.map { container(1.01, 1.01) }
    excluded = container(1.01, 1.01, sub_program: @other_sub_program)

    [
      { materials: "#{@material.id},#{@other_material.id}", expected: members + [excluded] },
      { wastes: "#{@waste.id},#{@other_waste.id}", expected: members + [excluded] },
      { materials: @material.id.to_s, expected: members },
      { wastes: @waste.id.to_s, expected: members }
    ].each do |filter|
      expected = filter.delete(:expected).map(&:id).sort
      cluster = only_result(search('containers_bbox4materials', filter.merge(clustered: 'true')))
      assert_equal expected, cluster['ids'].sort
      assert_equal expected.length, cluster['count']
      assert cluster['ids'].all? { |id| id.is_a?(Integer) && id > 0 }
    end

    cluster = only_result(search('containers_bbox4materials', version: '2', dimensions: @material.id.to_s, clustered: 'true'))
    assert_equal members.map(&:id).sort, cluster['ids'].sort
    assert_equal 105, cluster['count']
    assert_equal 50, search('containers_bbox4materials', version: '2', dimensions: @material.id.to_s).length
    looked_up = cluster['ids'].each_slice(100).flat_map do |ids|
      get '/api/containers', params: { container_ids: ids.join(',') }
      assert_response :success
      JSON.parse(response.body).map { |pin| pin['id'] }
    end
    assert_equal cluster['ids'].sort, looked_up.sort
  end

  test 'the filtered endpoint without a filter returns the same clustered results' do
    container(1.01, 1.01)
    container(1.02, 1.02)
    container(3, 3)
    assert_equal search('containers_bbox', clustered: 'true'),
                 search('containers_bbox4materials', clustered: 'true')
  end

  test 'a nonpositive database id remains a singleton rather than entering a cluster' do
    unusual = container(1.01, 1.01, id: -1)
    members = 2.times.map { container(1.01, 1.01) }
    results = search('containers_bbox', clustered: 'true')
    assert_equal unusual.id, results.find { |item| item['id'] == unusual.id }['id']
    assert_equal members.map(&:id), results.find { |item| item['cluster'] }['ids']
  end

  test 'includes bbox and cell boundaries including antimeridian and zero size bounds' do
    southwest = container(0, 0)
    near = container(0.01, 0.01)
    boundary = container(0.1, 0.1)
    northeast = container(4, 4)
    result = search('containers_bbox', clustered: 'true')
    assert_equal [southwest.id, near.id], result.find { |item| item['cluster'] }['ids']
    assert_equal [boundary.id, northeast.id].sort, result.map { |item| item['id'] }.compact.sort

    east = container(0, 179.99)
    west = container(0, -180)
    dateline = search('containers_bbox', sw: '0,179.01', ne: '1,-179', clustered: 'true')
    assert_equal [east.id, west.id], only_result(dateline)['ids']
    zero = search('containers_bbox', sw: '0,0', ne: '0,0', clustered: 'true')
    assert_equal southwest.id, only_result(zero)['id']
  end

  test 'rejects invalid clustering parameters' do
    [
      { clustered: 'yes' },
      { clustered: 'true', sw: 'x,0' },
      { clustered: 'true', sw: 'NaN,0' },
      { clustered: 'true', sw: '91,0' },
      { clustered: 'true', ne: '-1,1' },
      { clustered: 'true', ne: '4,181' },
      { clustered: 'true', sw: '1,2,3' },
      { clustered: 'true', sw: ['0', '0'] },
      { clustered: 'true', materials: '1,0' },
      { clustered: 'true', wastes: '1,abc' },
      { clustered: 'true', dimensions: '' }
    ].each do |invalid|
      get '/api/containers_bbox4materials', params: @bounds.merge(version: '2').merge(invalid)
      assert_response :bad_request
      assert JSON.parse(response.body)['error'].present?
    end
  end

  test 'container id lookup remains available for cluster members' do
    members = 2.times.map { container(1.01, 1.01) }
    ids = only_result(search('containers_bbox', clustered: 'true'))['ids']
    get '/api/containers', params: { container_ids: ids.join(',') }
    assert_response :success
    assert_equal members.map(&:id).sort, JSON.parse(response.body).map { |pin| pin['id'] }.sort
  end

  test 'cluster_details returns pins with the sub program name for visible members' do
    @sub_program.update!(name: 'Paper program')
    members = 2.times.map { container(1.01, 1.01) }
    hidden = container(1.01, 1.01, hidden: true)
    ids = only_result(search('containers_bbox', clustered: 'true'))['ids']
    get '/api/cluster_details', params: { version: '2', ids: (ids + [hidden.id]).join(',') }
    assert_response :success
    result = JSON.parse(response.body)
    assert_equal members.map(&:id), result.map { |pin| pin['id'] }
    assert result.all? { |pin| pin['sub_program_name'] == 'Paper program' && pin['sub_program_id'] == @sub_program.id }
    assert result.all? { |pin| pin.key?('latitude') && pin.key?('main_material') && pin.key?('custom_icon') }
  end

  test 'cluster_details validates ids' do
    ['', 'a,1', '0', '1,,2', (1..501).to_a.join(',')].each do |ids|
      get '/api/cluster_details', params: { version: '2', ids: ids }
      assert_response :bad_request
    end
    get '/api/cluster_details', params: { version: '2' }
    assert_response :bad_request
  end

  private

  def container(latitude, longitude, **attributes)
    Container.create!({
      sub_program: @sub_program, container_type: @type,
      latitude: latitude, longitude: longitude, public_site: true, hidden: false
    }.merge(attributes))
  end

  def search(endpoint, params = {})
    get "/api/#{endpoint}", params: @bounds.merge(version: '2').merge(params)
    assert_response :success
    JSON.parse(response.body)
  end

  def only_result(results)
    assert_equal 1, results.length
    results.first
  end
end
