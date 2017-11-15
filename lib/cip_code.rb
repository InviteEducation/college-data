require 'csv'

class CipCode

  @@codes = nil

  attr_reader :code, :name, :parent

  def initialize(code, name, parent = nil)
    @code = code
    @name = name
    if parent and parent.is_a?(CipCode)
      @parent = parent
      @parent.add_child(self)
    end
    @children = {} # ruby >= 1.9 maintains insertion order
  end

  def children
    @children.values.dup
  end

  def to_h
    { name: @name, code: @code }
  end

  def self.codes
    unless @@codes
      csv_file = File.join(Rails.root, 'data', 'cip_codes.csv')
      puts "Loading CIP codes from #{csv_file}"
      roots = []
      parent = nil
      CSV.foreach(csv_file, headers: true) do |row|
        code = row['CIPCode'].strip
        name = row['CIPTitle'].strip.titleize.gsub(/\.\z/,'').gsub(/,\s+And\s+/,' and ')
        if code.length == 2
          parent = CipCode.new(code, name)
          roots.push(parent)
        elsif code.length == 7
          child = CipCode.new(code, name, parent)
        else
          # skip second level categories
        end
      end
      @@codes = roots
    end
    @@codes
  end

  protected

  def add_child(child)
    @children[child.code] = child
  end

end