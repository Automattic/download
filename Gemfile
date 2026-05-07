# frozen_string_literal: true

source 'https://rubygems.org'

gem 'fastlane', '~> 2.232'
gem 'fastlane-plugin-wpmreleasetoolkit', '~> 12.3'
# To avoid errors like:
#
# SSL_connect returned=1 errno=0 peeraddr=3.5.132.155:443 state=error: certificate verify failed (unable to get certificate CRL)
#
# See https://github.com/ruby/openssl/issues/949
gem 'openssl', '~> 4.0'

# Pinned to pull in the fix for GHSA-c4rq-3m3g-8wgx (CSS selector ReDoS).
# Drop once `fastlane-plugin-wpmreleasetoolkit` moves to >= 14.4.1, whose
# gemspec carries this floor transitively.
gem 'nokogiri', '>= 1.19.3'
