class User < ActiveRecord::Base
  include ActsAsBits
  acts_as_bits :flags,  %w( superuser )

  ######################################################################
  ### Validations

  validates_presence_of :user
  validates_uniqueness_of :user

  ######################################################################
  ### Instance Methods

  ######################################################################
  ### Actions

  def login
    if logined_at.nil? or logined_at + 6.hours <= Time.now
      self.exp = self.exp.to_i + 1
    end
    self.logined_at = Time.now
  end

  ######################################################################
  ### Testing

  def local_account?
    !password.blank?
  end

  ######################################################################
  ### Printing

  def to_label
    if !name.blank?
      name
    else
      user
    end
  end

  ######################################################################
  ### Class Methods

  class << self
    def register(user, pass = nil)
      user = find_by_user(user) || new(:user=>user, :pass=>pass.to_s)
      user.login
      user.save!
      return user
    end

    # authorize as local account
    def authorize(user, pass)
      user = User.find_by_user(user.to_s) or return nil
      return nil unless user
      return nil unless user.local_account?
      return nil unless user.pass.to_s == pass.to_s
      return user
    end

    def reset_root_account
      root = find_or_create_by_user('root')
      root.pass  = 'root'
      root.superuser = true
      root.save!
    end
  end

end
