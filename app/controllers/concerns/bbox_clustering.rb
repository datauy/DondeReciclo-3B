module BboxClustering
  extend ActiveSupport::Concern

  GRID_SIZE = 40
  MAX_CLUSTER_DETAIL_IDS = 100

  included do
    before_action :validate_clustered_bbox, only: [:containers_bbox, :containers_bbox4materials]
    before_action :validate_cluster_detail_ids, only: :cluster_details
  end

  private

  def validate_clustered_bbox
    flag = params[:clustered]
    unless flag.nil? || flag == 'false' || flag == 'true'
      return render json: { error: 'clustered must be true or false' }, status: :bad_request
    end
    return unless clustered?

    @cluster_sw = parse_cluster_coordinate(params[:sw])
    @cluster_ne = parse_cluster_coordinate(params[:ne])
    unless @cluster_sw && @cluster_ne &&
        @cluster_sw[0].between?(-90, 90) && @cluster_ne[0].between?(-90, 90) &&
        @cluster_sw[1].between?(-180, 180) && @cluster_ne[1].between?(-180, 180) &&
        @cluster_sw[0] <= @cluster_ne[0]
      return render json: { error: 'sw and ne must be valid latitude,longitude bounds' }, status: :bad_request
    end

    [:materials, :wastes, :dimensions].each do |filter|
      next unless params.key?(filter)
      value = params[filter]
      unless value.is_a?(String) && value.match?(/\A[1-9]\d*(,[1-9]\d*)*\z/)
        return render json: { error: "#{filter} must be a comma-separated list of positive IDs" }, status: :bad_request
      end
    end
  end

  def validate_cluster_detail_ids
    value = params[:container_ids]
    unless value.is_a?(String) && value.match?(/\A[1-9]\d*(,[1-9]\d*)*\z/)
      return render json: { error: 'ids must be a comma-separated list of positive IDs' }, status: :bad_request
    end
    @cluster_detail_ids = value.split(',').map(&:to_i).uniq
    if @cluster_detail_ids.length > MAX_CLUSTER_DETAIL_IDS
      render json: { error: "ids must contain at most #{MAX_CLUSTER_DETAIL_IDS} values" }, status: :bad_request
    end
  end

  def parse_cluster_coordinate(value)
    return unless value.is_a?(String)
    parts = value.split(',', -1)
    return unless parts.length == 2
    coordinates = parts.map { |part| Float(part) }
    coordinates if coordinates.all?(&:finite?)
  rescue ArgumentError, TypeError
    nil
  end

  def clustered?
    params[:clustered] == 'true'
  end

  def bbox_bounds
    clustered? ? [@cluster_sw, @cluster_ne] : [params[:sw].split(','), params[:ne].split(',')]
  end

  def render_bbox_containers(containers)
    return render json: format_pins(containers) unless clustered?

    south, west = @cluster_sw
    north, east = @cluster_ne
    longitude_span = east - west
    longitude_span += 360 if longitude_span < 0

    # Matching ids only; eager loads and the limit are irrelevant to the aggregation.
    matching = containers.except(:limit, :order, :includes, :preload, :eager_load, :references).
      reselect('containers.id')
    lat_cell = cluster_cell_sql('containers.latitude::double precision', south, north - south)
    lon_cell = cluster_cell_sql(
      "(CASE WHEN containers.longitude::double precision < #{west.to_f} THEN containers.longitude::double precision + 360 " \
      'ELSE containers.longitude::double precision END)', west, longitude_span
    )
    # Non-positive ids never join a cluster; each gets its own group.
    individual = 'CASE WHEN containers.id > 0 THEN 0 ELSE containers.id END'
    rows = Container.where(id: matching).group(lat_cell, lon_cell, individual).order(Arel.sql('MIN(containers.id)')).pluck(
      Arel.sql('COUNT(*) AS member_count'),
      Arel.sql('(ARRAY_AGG(containers.latitude::double precision ORDER BY containers.id))[1] AS rep_latitude'),
      Arel.sql('(ARRAY_AGG(containers.longitude::double precision ORDER BY containers.id))[1] AS rep_longitude'),
      Arel.sql('ARRAY_AGG(containers.id ORDER BY containers.id) AS member_ids')
    )

    singles = rows.select { |count, *| count == 1 }.map { |_, _, _, ids| ids.first }
    pins = Container.where(id: singles).includes(:sub_program, custom_icon_attachment: :blob).
      index_by(&:id)

    results = rows.flat_map do |count, latitude, longitude, ids|
      if count == 1
        format_pins([pins.fetch(ids.first)])
      else
        [{ cluster: true, latitude: latitude.to_f, longitude: longitude.to_f, count: count, ids: ids }]
      end
    end
    render json: results
  end

  def cluster_cell_sql(offset_sql, origin, span)
    return '(0)::int' if span.zero?
    "LEAST(FLOOR((#{offset_sql} - #{origin.to_f}) / #{span.to_f} * #{GRID_SIZE}), #{GRID_SIZE - 1})::int"
  end
end
