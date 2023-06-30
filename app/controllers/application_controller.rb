# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protected

  def redirect_with_alert(path, msg)
    redirect_by_kind(path, :alert, msg)
  end

  def redirect_with_notice(path, msg)
    redirect_by_kind(path, :notice, msg)
  end

  def redirect_by_kind(path, kind, msg)
    flash[kind] = msg
    redirect_to path
  end
end
