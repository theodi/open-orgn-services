module Helpers
  def remove_env_var(name, &block)
    env_var = ENV.delete(name)
    block.call
    ENV[name] = env_var
  end
end

