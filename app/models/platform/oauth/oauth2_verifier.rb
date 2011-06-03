class Platform::Oauth::Oauth2Verifier < Platform::Oauth::OauthToken

  validates_presence_of :user

  def exchange!(params={})
    OauthToken.transaction do
      token = Oauth2Token.create! :user => user, :application => application
      invalidate!
      token
    end
  end

  def code
    token
  end

  def redirect_url
    callback_url
  end

  protected

  def generate_keys
    self.token = OAuth::Helper.generate_key(20)[0,20]
    self.valid_to = 10.minutes.from_now
    self.authorized_at = Time.now
  end

end
