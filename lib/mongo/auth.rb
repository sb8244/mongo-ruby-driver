# Copyright (C) 2009-2014 MongoDB, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'mongo/auth/executable'
require 'mongo/auth/cr'
require 'mongo/auth/ldap'
# require 'mongo/auth/kerberos' if BSON::Environment.jruby?
require 'mongo/auth/user'
require 'mongo/auth/x509'

module Mongo

  # This namespace contains all authentication related behaviour.
  #
  # @since 2.0.0
  module Auth
    extend self

    # The external database name.
    #
    # @since 2.0.0
    EXTERNAL = '$external'.freeze

    # Constant for the nonce command.
    #
    # @since 2.0.0
    GET_NONCE = { getnonce: 1 }.freeze

    # Constant for the nonce field.
    #
    # @since 2.0.0
    NONCE = 'nonce'.freeze

    # Map the symbols parsed from the URI connection string to strategies.
    #
    # @since 2.0.0
    SOURCES = {
      # gssapi: Kerberos,
      mongodb_cr: CR,
      mongodb_x509: X509,
      plain: LDAP,
    }.freeze

    # Get the authorization strategy for the provided auth mechanism.
    #
    # @example Get the strategy.
    #   Auth.get(:mongodb_cr)
    #
    # @param [ Symbol ] mechanism The authorization mechanism.
    #
    # @return [ CR, X509, LDAP, Kerberos ] The auth strategy.
    #
    # @since 2.0.0
    def get(mechanism = nil)
      raise InvalidMechanism.new(mechanism) if mechanism && !SOURCES.has_key?(mechanism)
      SOURCES[mechanism || :mongodb_cr]
    end

    # Raised when trying to get an invalid authorization mechanism.
    #
    # @since 2.0.0
    class InvalidMechanism < RuntimeError

      # Instantiate the new error.
      #
      # @example Instantiate the error.
      #   Mongo::Auth::InvalidMechanism.new(:test)
      #
      # @param [ Symbol ] mechanism The provided mechanism.
      #
      # @since 2.0.0
      def initialize(mechanism)
        super("#{mechanism.inspect} is invalid, please use mongodb_cr, mongodb_x509, gssapi or plain.")
      end
    end

    # Raised when a user is not authorized on a database.
    #
    # @since 2.0.0
    class Unauthorized < RuntimeError

      # Instantiate the new error.
      #
      # @example Instantiate the error.
      #   Mongo::Auth::Unauthorized.new(user)
      #
      # @param [ Mongo::Auth::User ] user The unauthorized user.
      #
      # @since 2.0.0
      def initialize(user)
        super("User #{user.name} is not authorized to access #{user.database}.")
      end
    end
  end
end
