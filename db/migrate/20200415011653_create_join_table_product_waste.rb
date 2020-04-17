class CreateJoinTableProductWaste < ActiveRecord::Migration[6.0]
  def change
    create_join_table :products, :wastes do |t|
      t.index [:product_id, :waste_id]
      # t.index [:waste_id, :product_id]
    end
  end
end
