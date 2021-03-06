#--
# Copyright (c) 2011 Michael Berkovich
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

class Platform::Admin::AppsController < Platform::Admin::BaseController

  def index
    @apps = Platform::Application.filter(:params => params, :filter => Platform::ApplicationFilter)
  end

  def view
    @app = Platform::Application.find(params[:app_id])
  end
  
  def tokens
    @tokens = Platform::Oauth::OauthToken.filter(:params => params, :filter => Platform::Oauth::OauthTokenFilter)
  end

  def users
    @users = Platform::ApplicationUser.filter(:params => params, :filter => Platform::ApplicationUserFilter)
  end

  def permissions
    @permissions = Platform::ApplicationPermission.filter(:params => params, :filter => Platform::ApplicationPermissionFilter)
  end

  def ratings
    @ratings = Platform::Rating.filter(:params => params, :filter => Platform::RatingFilter)
  end

  def block
    app = Platform::Application.find(params[:app_id])  
    app.block!
    
    app.children.each do |child|
      child.block!
    end
    
    redirect_to(:action => :view, :app_id => app.id)
  end

  def unblock
    app = Platform::Application.find(params[:app_id])  
    app.unblock!
    redirect_to(:action => :view, :app_id => app.id)
  end

  def approve
    app = Platform::Application.find(params[:app_id])
    
    app.children.each do |child|
      child.deprecate!
    end
    
    app.approve!
    
    redirect_to(:action => :view, :app_id => app.id)
  end

  def reject
    app = Platform::Application.find(params[:app_id])  
    app.reject!
    redirect_to(:action => :view, :app_id => app.id)
  end

  def set_permission
    app = Platform::Application.find(params[:app_id])  
    app.set_permission(params[:perm], true)
    app.save
    redirect_to(:action => :view, :app_id => app.id)
  end

  def remove_permission
    app = Platform::Application.find(params[:app_id])  
    app.set_permission(params[:perm], false)
    app.save
    redirect_to(:action => :view, :app_id => app.id)
  end
  
end
