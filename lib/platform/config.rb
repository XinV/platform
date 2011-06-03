class Platform::Config

  def self.init(site_current_user)
    Thread.current[:platform_current_user] = site_current_user
    Thread.current[:platform_current_developer] = Platform::Developer.for(site_current_user)
  end

  def self.current_user
    Thread.current[:platform_current_user]
  end

  def self.current_developer
    Thread.current[:platform_current_developer] 
  end

  def self.current_user_is_developer?
    Thread.current[:platform_current_developer] != nil
  end

  def self.reset!
    Thread.current[:platform_current_user] = nil
    Thread.current[:platform_current_developer] = nil
  end

  def self.models
    [
      Platform::Developer, Platform::Application
    ]
  end
  
  def self.reset_all!
    models.each do |cls|
      puts ">> Resetting #{cls.name}..."
      cls.delete_all
    end

    puts "Done."
  end

  def self.root
    Rails.root
  end
  
  def self.env
    Rails.env
  end

  def self.load_yml(file_path, for_env = env)
    yml = YAML.load_file("#{root}#{file_path}")
    yml = yml[for_env] unless for_env.nil?
    HashWithIndifferentAccess.new(yml)
  end

  def self.config
    @config ||= load_yml("/config/platform/config.yml")
  end

  def self.enabled?
    config[:enable_platform] 
  end

  def self.disabled?
    not enabled?
  end

  def self.enable_app_directory?
    config[:enable_app_directory]
  end

  def self.enable_embedded_applications?
    config[:enable_embedded_applications]
  end

  def self.default_app_icon
    "/platform/images/default_app_icon.gif"
  end
  
  def self.default_app_logo
    "/platform/images/default_app_logo.gif"
  end  
  
  #########################################################
  # Config Sections
  def self.caching
    config[:caching]
  end

  def self.logger
    config[:logger]
  end
  
  def self.site_info
    config[:site_info]
  end
  #########################################################

  #########################################################
  # Caching
  def self.enable_caching?
    caching[:enabled]
  end

  def self.cache_adapter
    caching[:adapter]
  end

  def self.cache_store
    caching[:store]
  end

  def self.cache_version
    caching[:version]
  end
  #########################################################

  #########################################################
  # Logger
  def self.enable_logger?
    logger[:enabled]
  end

  def self.log_path
    logger[:log_path]
  end
  #########################################################

  #########################################################
  # Site Info
  def self.site_title
    site_info[:title] 
  end

  def self.default_url
    site_info[:default_url]
  end

  def self.site_layout
    site_info[:layout]
  end

  def self.helpers
    return [] unless site_info[:helpers]
    @tr8n_helpers ||= site_info[:helpers].collect{|helper| helper.to_sym}
  end

  def self.admin_helpers
    return [] unless site_info[:admin_helpers]
    @admin_helpers ||= site_info[:admin_helpers].collect{|helper| helper.to_sym}
  end
  
  def self.skip_before_filters
    return [] unless site_info[:skip_before_filters]
    @skip_before_filters ||= site_info[:skip_before_filters].collect{|filter| filter.to_sym}
  end

  def self.before_filters
    return [] unless site_info[:before_filters]
    @before_filters ||= site_info[:before_filters].collect{|filter| filter.to_sym}
  end

  def self.after_filters
    return [] unless site_info[:after_filters]
    @after_filters ||= site_info[:after_filters].collect{|filter| filter.to_sym}
  end

  #########################################################
  # site user info
  # The following methods could be overloaded in the initializer
  #########################################################
  def self.site_user_info
    site_info[:user_info]
  end

  def self.current_user_method
    site_user_info[:current_user_method]
  end

  def self.site_user_info_enabled?
    site_user_info[:enabled].nil? ? true : site_user_info[:enabled]
  end

  def self.site_user_info_disabled?
    !site_user_info_enabled?
  end
  
  def self.user_class_name
    return site_user_info[:class_name] if site_user_info_enabled?
    "Platform::Developer"  
  end

  def self.user_class
    user_class_name.constantize
  end

  def self.user_id(user)
    begin
      user.send(site_user_info[:methods][:id])
    rescue Exception => ex
      Platform::Logger.error("Failed to fetch user id: #{ex.to_s}")
      return 0
    end  
  end

  def self.user_name(user)
    begin
      user.send(site_user_info[:methods][:name])
    rescue Exception => ex
      Platform::Logger.error("Failed to fetch #{user_class_name} name: #{ex.to_s}")
      return "Unknown user"
    end  
  end

  def self.user_gender(user)
    begin
      user.send(site_user_info[:methods][:gender])
    rescue Exception => ex
      Platform::Logger.error("Failed to fetch #{user_class_name} name: #{ex.to_s}")
      return "unknown"
    end  
  end

  def self.user_mugshot(user)
    begin
      user.send(site_user_info[:methods][:mugshot])
    rescue Exception => ex
      Platform::Logger.error("Failed to fetch #{user_class_name} image: #{ex.to_s}")
      return silhouette_image
    end  
  end

  def self.user_link(user)
    begin
      user.send(site_user_info[:methods][:link])
    rescue Exception => ex
      Platform::Logger.error("Failed to fetch #{user_class_name} link: #{ex.to_s}")
      return "/tr8n"
    end  
  end

  def self.user_locale(user)
    begin
      user.send(site_user_info[:methods][:locale])
    rescue Exception => ex
      Platform::Logger.error("Failed to fetch #{user_class_name} locale: #{ex.to_s}")
      return default_locale
    end  
  end

  def self.admin_user?(user = current_user)
    begin
      user.send(site_user_info[:methods][:admin])
    rescue Exception => ex
      Platform::Logger.error("Failed to fetch #{user_class_name} admin flag: #{ex.to_s}")
      return false
    end  
  end

  def self.current_user_is_admin?
    admin_user?
  end
  
  def self.guest_user?(user = current_user)
    return true unless user
    begin
      user.send(site_user_info[:methods][:guest])
    rescue Exception => ex
      Platform::Logger.error("Failed to fetch #{user_class_name} guest flag: #{ex.to_s}")
      return true
    end  
  end
  
  def self.current_user_is_guest?
    guest_user?
  end
  #########################################################

end
