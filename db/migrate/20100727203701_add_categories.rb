class AddCategories < ActiveRecord::Migration
  def self.up
    Category.create({:name => 'Transfer'})
    Category.create({:name => 'Lebensmittel'})
    Category.create({:name => 'Gehalt'})
    Category.create({:name => 'Miete'})
  end

  def self.down
  end
end
