class PrototypedObject
  attr_accessor :klass, :instance, :methods, :properties

  def initialize
    self.klass = Class.new
    self.instance = self.klass.new
    self.methods = {}
    self.properties = []
  end

  def method_missing(symbol, *args)
    super unless self.get_methods.include? symbol
    self.instance.send symbol, *args
  end

  def get_methods
    (self.klass.instance_methods - Object.instance_methods)
  end

  def set_property(sym_property, value)

    self.klass.instance_eval do
      attr_accessor sym_property
    end

    self.properties << sym_property
    self.instance.send "#{sym_property}=", value
  end

  def set_method(symbol, block)
    self.methods[symbol] = block
    self.klass.send :define_method, symbol, block
  end

  def clone
    new_class = Class.new

    #Migrar los metodos de comportamiento
    self.methods.each do |sym, block|
      new_class.send :define_method, sym, block
    end

    #Migrar los metodos de seteo de propiedades
    self.properties.each do |sym|
      new_class.instance_eval do
        attr_accessor sym
      end
    end

    instance = new_class.new

    #Seteo ahora el estado
    self.instance.instance_variables.each do |var|
      value=self.instance.instance_variable_get var
      instance.instance_variable_set var, value
    end

    instance
  end

  def set_prototype(prototype)
    self.klass = Class.new(prototype.klass) {}
    self.instance = self.klass.new
  end


end