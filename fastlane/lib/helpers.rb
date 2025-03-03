# frozen_string_literal: true

def prompt_user_for_app_store_connect_credentials
  require 'credentials_manager'

  # If Fastlane cannot instantiate a user, it will ask the caller for the email.
  # Once we have it, we can set it as `FASTLANE_USER` in the environment (which has lifecycle limited to this call) so that the next commands will already have access to it.
  # Note: if the user is already available to `AccountManager`, setting it in the env is redundant, but Fastlane doesn't provide a way to check it so we have to do it anyway.
  ENV['FASTLANE_USER'] = CredentialsManager::AccountManager.new.user
end
