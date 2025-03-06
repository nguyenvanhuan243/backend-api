require 'jwt'
class Authenticate
  ALGORITHM = 'HS256'
  def self.issue(payload)
    JWT.encode(payload, ENV['AUTH_SECRET'], ALGORITHM)
  end

  def self.decode(token)
    JWT.decode(token, ENV['AUTH_SECRET'], true, { algorithm: "HS256" }).first
  end

  def self.jwt_valid?(token)
    return false unless token

    begin
      decoded_token = decode(token)
      return true
    rescue JWT::DecodeError
      Rails.logger.warn 'Error decoding the JWT'
    end
    false
  end
end
