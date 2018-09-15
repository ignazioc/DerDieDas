class Result
  def initialize
    @arg = nil
    @autocomplete = nil
    @icon = nil
    @mods = {}
    @quicklookurl = nil
    @subtitle = nil
    @text = {}
    @title = nil
    @type = nil
    @uid = nil
    @valid = true

    @simple_values = %w[
      arg
      autocomplete
      quicklookurl
      subtitle
      title
      uid
    ]

    @valid_values = {
      type: ['default', 'file', 'file:skipcheck'],
      icon: %w[fileicon filetype],
      text: %w[copy largetype],
      mod: %w[shift fn ctrl alt cmd]
    }
  end

  public

  def valid(valid)
    @valid = !!valid
    self
  end

  public

  def type(type, verify_existence = true)
    return self unless @valid_values[:type].include?(type.to_s)

    @type = if type === 'file' && !verify_existence
              'file:skipcheck'
            else
              type
            end

    self
  end

  public

  def icon(path, type = nil)
    @icon = {
      path: path
    }

    @icon[:type] = type if @valid_values[:icon].include?(type.to_s)

    self
  end

  public

  def fileicon_icon(path)
    icon(path, 'fileicon')
  end

  public

  def filetype_icon(path)
    icon(path, 'filetype')
  end

  public

  def text(type, text)
    return self unless @valid_values[:text].include?(type.to_s)

    @text[type.to_sym] = text

    self
  end

  public

  def mod(mod, subtitle, arg, valid = true)
    return self unless @valid_values[:mod].include?(mod.to_s)

    @mods[mod.to_sym] = {
      subtitle: subtitle,
      arg: arg,
      valid: valid
    }

    self
  end

  public

  def to_hash
    keys = %w[
      arg
      autocomplete
      icon
      mods
      quicklookurl
      subtitle
      text
      title
      type
      uid
      valid
    ]

    result = {}

    keys.each do |key|
      result[key.to_sym] = instance_variable_get("@#{key}")
    end

    result.select do |_hash_key, hash_value|
      (hash_value.class.to_s === 'Hash' && !hash_value.empty?) || (hash_value.class.to_s != 'Hash' && !hash_value.nil?)
    end
  end

  def method_missing(method, *arguments)
    if @simple_values.include?(method.to_s)
      instance_variable_set("@#{method}", arguments.first)
      return self
    end

    return mod(method, *arguments) if @valid_values[:mod].include?(method.to_s)

    return text(method, *arguments) if @valid_values[:text].include?(method.to_s)

    super
  end

  def respond_to?(method, include_private = false)
    return true if @simple_values.include?(method.to_s)

    return true if @valid_values[:mod].include?(method.to_s)

    return true if @valid_values[:text].include?(method.to_s)

    super
  end
end
