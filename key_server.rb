require 'SecureRandom'

class KeyServer
  def initialize
    @unblocked = {}
    @blocked = {}
  end
 
  def create
    uuid = SecureRandom.uuid
    @unblocked[uuid] = {'alive_time'=>Time.now.to_i + 300}
    uuid
  end

  def fetch_available_one
    return nil if @unblocked.empty?
    key, ts = @unblocked.first
    ts['block_time'] = Time.now.to_i + 60
    @unblocked.delete(key)
    @blocked[key] = ts
    key
  end

  def unblock key
    ts = @blocked.delete(key)
    ts.delete('block_time')
    @unblocked[key] = ts
    key
  end

  def delete key
    @unblocked.delete(key)
    @blocked.delete(key)
  end

  def keep_alive key
    if @blocked.key? key
      @blocked[key]['alive_time'] = Time.now.to_i + 300
    elsif @unblocked.key? key
      @unblocked[key]['alive_time'] = Time.now.to_i + 300
    end
  end

  def getall
    {'blocked': @blocked,
    'unblocked': @unblocked}
  end

  def cleanup
    now = Time.now.to_i
    @unblocked.each do |key, timestamps|
      if timestamps["alive_time"] <= now
        @unblocked.delete(key)
      end
    end
    @blocked.each do |key, timestamps|
      if timestamps["alive_time"] <= now
        @blocked.delete(key)
      elsif timestamps['block_time'] <= now
        timestamps.delete('block_time')
        @blocked.delete(key)
        @unblocked[key] = timestamps
      end
    end
  end
end