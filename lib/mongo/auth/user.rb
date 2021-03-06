# Copyright (C) 2009 - 2014 MongoDB Inc.
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

module Mongo
  module Auth

    # Represents a user in MongoDB.
    #
    # @since 2.0.0
    class User

      # @return [ String ] The database the user is created in.
      attr_reader :database

      # @return [ String ] The username.
      attr_reader :name

      # @return [ String ] The cleartext password.
      attr_reader :password

      # Determine if this user is equal to another.
      #
      # @example Check user equality.
      #   user == other
      #
      # @param [ Object ] other The object to compare against.
      #
      # @return [ true, false ] If the objects are equal.
      #
      # @since 2.0.0
      def ==(other)
        return false unless other.is_a?(User)
        name == other.name && database == other.database && password == other.password
      end

      # Get an authentication key for the user based on a nonce from the
      # server.
      #
      # @example Get the authentication key.
      #   user.auth_key(nonce)
      #
      # @param [ String ] nonce The response from the server.
      #
      # @return [ String ] The authentication key.
      #
      # @since 2.0.0
      def auth_key(nonce)
        Digest::MD5.hexdigest("#{nonce}#{name}#{hashed_password}")
      end

      # Get the hash key for the user.
      #
      # @example Get the hash key.
      #   user.hash
      #
      # @return [ String ] The user hash key.
      #
      # @since 2.0.0
      def hash
        [ name, database, password ].hash
      end

      # Get the user's hashed password.
      #
      # @example Get the user's hashed password.
      #   user.hashed_password
      #
      # @return [ String ] The hashed password.
      #
      # @since 2.0.0
      def hashed_password
        @hashed_password ||= Digest::MD5.hexdigest("#{name}:mongo:#{password}")
      end

      # Create the new user.
      #
      # @example Create a new user.
      #   Mongo::Auth::User.new('testing', 'user', 'password')
      #
      # @param [ String ] database The database to create the user on.
      # @param [ String ] name The username.
      # @param [ String ] password The password.
      #
      # @since 2.0.0
      def initialize(database, name, password)
        @database = database
        @name = name
        @password = password
      end
    end
  end
end
