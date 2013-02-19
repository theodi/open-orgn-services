class User
  def initialize(user)
    Resque.enqueue(SignupProcessor, user)
  end
end