#encoding:utf-8
#
# 處理玩家人物的類。擁有事件啟動的判定、地圖的卷動等功能。
# 本類的案例請參考 $game_player 。
#

class Game_Player < Game_Character
  #
  # 定義案例變量
  #
  #
  attr_reader   :followers                # 跟隨角色（隊伍成員）
  #
  # 初始化物件
  #
  #
  def initialize
    super
    @vehicle_type = :walk           # 當前乘坐載具的種類
    @vehicle_getting_on = false     # 正在登上載具的標志
    @vehicle_getting_off = false    # 正在離開載具的標志
    @followers = Game_Followers.new(self)
    @transparent = $data_system.opt_transparent
    clear_transfer_info
  end
  #
  # 清除場所搬移的訊息
  #
  #
  def clear_transfer_info
    @transferring = false           # 場所搬移的標志
    @new_map_id = 0                 # 搬移後的地圖 ID
    @new_x = 0                      # 搬移後的X 坐標
    @new_y = 0                      # 搬移後的Y 坐標
    @new_direction = 0              # 搬移後的方向
  end
  #
  # 重新整理
  #
  #
  def refresh
    @character_name = actor ? actor.character_name : ""
    @character_index = actor ? actor.character_index : 0
    @followers.refresh
  end
  #
  # 取得對應的角色
  #
  #
  def actor
    $game_party.battle_members[0]
  end
  #
  # 判定是否靜止
  #
  #
  def stopping?
    return false if @vehicle_getting_on || @vehicle_getting_off
    return super
  end
  #
  # 預定場所搬移的位置
  #
  # d : 搬移後的方向（2,4,6,8）
  #
  def reserve_transfer(map_id, x, y, d = 2)
    @transferring = true
    @new_map_id = map_id
    @new_x = x
    @new_y = y
    @new_direction = d
  end
  #
  # 判定是否預定了場所搬移的行為
  #
  #
  def transfer?
    @transferring
  end
  #
  # 執行場所搬移
  #
  #
  def perform_transfer
    if transfer?
      set_direction(@new_direction)
      if @new_map_id != $game_map.map_id
        $game_map.setup(@new_map_id)
        $game_map.autoplay
      end
      moveto(@new_x, @new_y)
      clear_transfer_info
    end
  end
  #
  # 判定地圖能否通行
  #
  # d : 方向（2,4,6,8）
  #
  def map_passable?(x, y, d)
    case @vehicle_type
    when :boat
      $game_map.boat_passable?(x, y)
    when :ship
      $game_map.ship_passable?(x, y)
    when :airship
      true
    else
      super
    end
  end
  #
  # 取得當前乘坐載具
  #
  #
  def vehicle
    $game_map.vehicle(@vehicle_type)
  end
  #
  # 判定是否乘坐著小舟
  #
  #
  def in_boat?
    @vehicle_type == :boat
  end
  #
  # 判定是否乘坐著大船
  #
  #
  def in_ship?
    @vehicle_type == :ship
  end
  #
  # 判定是否乘坐著飛艇
  #
  #
  def in_airship?
    @vehicle_type == :airship
  end
  #
  # 判定是否正在步行
  #
  #
  def normal_walk?
    @vehicle_type == :walk && !@move_route_forcing
  end
  #
  # 判定是否跑步狀態
  #
  #
  def dash?
    return false if @move_route_forcing
    return false if $game_map.disable_dash?
    return false if vehicle
    return Input.press?(:A)
  end
  #
  # 判定是否除錯時穿透狀態
  #
  #
  def debug_through?
    $TEST && Input.press?(:CTRL)
  end
  #
  # 判定是否碰撞（包括跟隨角色）
  #
  #
  def collide?(x, y)
    !@through && (pos?(x, y) || followers.collide?(x, y))
  end
  #
  # 畫面中央的 X 坐標
  #
  #
  def center_x
    (Graphics.width / 32 - 1) / 2.0
  end
  #
  # 畫面中央的 Y 坐標
  #
  #
  def center_y
    (Graphics.height / 32 - 1) / 2.0
  end
  #
  # 設定顯示位置為地圖中央
  #
  #
  def center(x, y)
    $game_map.set_display_pos(x - center_x, y - center_y)
  end
  #
  # 搬移到指定位置
  #
  #
  def moveto(x, y)
    super
    center(x, y)
    make_encounter_count
    vehicle.refresh if vehicle
    @followers.synchronize(x, y, direction)
  end
  #
  # 增加步數
  #
  #
  def increase_steps
    super
    $game_party.increase_steps if normal_walk?
  end
  #
  # 生成遇敵計數
  #
  #
  def make_encounter_count
    n = $game_map.encounter_step
    @encounter_count = rand(n) + rand(n) + 1
  end
  #
  # 生成敵群的 ID 
  #
  #
  def make_encounter_troop_id
    encounter_list = []
    weight_sum = 0
    $game_map.encounter_list.each do |encounter|
      next unless encounter_ok?(encounter)
      encounter_list.push(encounter)
      weight_sum += encounter.weight
    end
    if weight_sum > 0
      value = rand(weight_sum)
      encounter_list.each do |encounter|
        value -= encounter.weight
        return encounter.troop_id if value < 0
      end
    end
    return 0
  end
  #
  # 判定是否會遇敵
  #
  #
  def encounter_ok?(encounter)
    return true if encounter.region_set.empty?
    return true if encounter.region_set.include?(region_id)
    return false
  end
  #
  # 執行遇敵處理
  #
  #
  def encounter
    return false if $game_map.interpreter.running?
    return false if $game_system.encounter_disabled
    return false if @encounter_count > 0
    make_encounter_count
    troop_id = make_encounter_troop_id
    return false unless $data_troops[troop_id]
    BattleManager.setup(troop_id)
    BattleManager.on_encounter
    return true
  end
  #
  # 啟動地圖事件
  #
  # triggers : 啟動模式的數組
  # normal   : 優先級“與人物一樣”還是其他
  #
  def start_map_event(x, y, triggers, normal)
    $game_map.events_xy(x, y).each do |event|
      if event.trigger_in?(triggers) && event.normal_priority? == normal
        event.start
      end
    end
  end
  #
  # 判定同位置事件是否被啟動
  #
  #
  def check_event_trigger_here(triggers)
    start_map_event(@x, @y, triggers, false)
  end
  #
  # 判定前方事件是否被啟動
  #
  #
  def check_event_trigger_there(triggers)
    x2 = $game_map.round_x_with_direction(@x, @direction)
    y2 = $game_map.round_y_with_direction(@y, @direction)
    start_map_event(x2, y2, triggers, true)
    return if $game_map.any_event_starting?
    return unless $game_map.counter?(x2, y2)
    x3 = $game_map.round_x_with_direction(x2, @direction)
    y3 = $game_map.round_y_with_direction(y2, @direction)
    start_map_event(x3, y3, triggers, true)
  end
  #
  # 判定接觸事件是否被啟動
  #
  #
  def check_event_trigger_touch(x, y)
    start_map_event(x, y, [1,2], true)
  end
  #
  # 由方向鍵搬移
  #
  #
  def move_by_input
    return if !movable? || $game_map.interpreter.running?
    move_straight(Input.dir4) if Input.dir4 > 0
  end
  #
  # 判定是否可以搬移
  #
  #
  def movable?
    return false if moving?
    return false if @move_route_forcing || @followers.gathering?
    return false if @vehicle_getting_on || @vehicle_getting_off
    return false if $game_message.busy? || $game_message.visible
    return false if vehicle && !vehicle.movable?
    return true
  end
  #
  # 更新畫面
  #
  #
  def update
    last_real_x = @real_x
    last_real_y = @real_y
    last_moving = moving?
    move_by_input
    super
    update_scroll(last_real_x, last_real_y)
    update_vehicle
    update_nonmoving(last_moving) unless moving?
    @followers.update
  end
  #
  # 處理卷動
  #
  #
  def update_scroll(last_real_x, last_real_y)
    ax1 = $game_map.adjust_x(last_real_x)
    ay1 = $game_map.adjust_y(last_real_y)
    ax2 = $game_map.adjust_x(@real_x)
    ay2 = $game_map.adjust_y(@real_y)
    $game_map.scroll_down (ay2 - ay1) if ay2 > ay1 && ay2 > center_y
    $game_map.scroll_left (ax1 - ax2) if ax2 < ax1 && ax2 < center_x
    $game_map.scroll_right(ax2 - ax1) if ax2 > ax1 && ax2 > center_x
    $game_map.scroll_up   (ay1 - ay2) if ay2 < ay1 && ay2 < center_y
  end
  #
  # 處理載具的升降與搬移
  #
  #
  def update_vehicle
    return if @followers.gathering?
    return unless vehicle
    if @vehicle_getting_on
      update_vehicle_get_on
    elsif @vehicle_getting_off
      update_vehicle_get_off
    else
      vehicle.sync_with_player
    end
  end
  #
  # 更新登上載具
  #
  #
  def update_vehicle_get_on
    if !@followers.gathering? && !moving?
      @direction = vehicle.direction
      @move_speed = vehicle.speed
      @vehicle_getting_on = false
      @transparent = true
      @through = true if in_airship?
      vehicle.get_on
    end
  end
  #
  # 更新離開載具
  #
  #
  def update_vehicle_get_off
    if !@followers.gathering? && vehicle.altitude == 0
      @vehicle_getting_off = false
      @vehicle_type = :walk
      @transparent = false
    end
  end
  #
  # 非搬移中的處理
  #
  # last_moving : 此前是否正在搬移
  #
  def update_nonmoving(last_moving)
    return if $game_map.interpreter.running?
    if last_moving
      $game_party.on_player_walk
      return if check_touch_event
    end
    if movable? && Input.trigger?(:C)
      return if get_on_off_vehicle
      return if check_action_event
    end
    update_encounter if last_moving
  end
  #
  # 更新遇敵
  #
  #
  def update_encounter
    return if $TEST && Input.press?(:CTRL)
    return if $game_party.encounter_none?
    return if in_airship?
    return if @move_route_forcing
    @encounter_count -= encounter_progress_value
  end
  #
  # 取得遇敵進行值
  #
  #
  def encounter_progress_value
    value = $game_map.bush?(@x, @y) ? 2 : 1
    value *= 0.5 if $game_party.encounter_half?
    value *= 0.5 if in_ship?
    value
  end
  #
  # 判定事件是否由接觸啟動（重疊）
  #
  #
  def check_touch_event
    return false if in_airship?
    check_event_trigger_here([1,2])
    $game_map.setup_starting_event
  end
  #
  # 判定事件是否由確認鍵啟動
  #
  #
  def check_action_event
    return false if in_airship?
    check_event_trigger_here([0])
    return true if $game_map.setup_starting_event
    check_event_trigger_there([0,1,2])
    $game_map.setup_starting_event
  end
  #
  # 載具的乘降
  #
  #
  def get_on_off_vehicle
    if vehicle
      get_off_vehicle
    else
      get_on_vehicle
    end
  end
  #
  # 登上載具
  #
  # 前提是沒有乘坐著載具。
  #
  def get_on_vehicle
    front_x = $game_map.round_x_with_direction(@x, @direction)
    front_y = $game_map.round_y_with_direction(@y, @direction)
    @vehicle_type = :boat    if $game_map.boat.pos?(front_x, front_y)
    @vehicle_type = :ship    if $game_map.ship.pos?(front_x, front_y)
    @vehicle_type = :airship if $game_map.airship.pos?(@x, @y)
    if vehicle
      @vehicle_getting_on = true
      force_move_forward unless in_airship?
      @followers.gather
    end
    @vehicle_getting_on
  end
  #
  # 離開載具
  #
  # 前提是乘坐著載具。
  #
  def get_off_vehicle
    if vehicle.land_ok?(@x, @y, @direction)
      set_direction(2) if in_airship?
      @followers.synchronize(@x, @y, @direction)
      vehicle.get_off
      unless in_airship?
        force_move_forward
        @transparent = false
      end
      @vehicle_getting_off = true
      @move_speed = 4
      @through = false
      make_encounter_count
      @followers.gather
    end
    @vehicle_getting_off
  end
  #
  # 強制前進一步
  #
  #
  def force_move_forward
    @through = true
    move_forward
    @through = false
  end
  #
  # 判定是否傷害地形
  #
  #
  def on_damage_floor?
    $game_map.damage_floor?(@x, @y) && !in_airship?
  end
  #
  # 徑向搬移
  #
  #
  def move_straight(d, turn_ok = true)
    @followers.move if passable?(@x, @y, d)
    super
  end
  #
  # 斜向搬移
  #
  #
  def move_diagonal(horz, vert)
    @followers.move if diagonal_passable?(@x, @y, horz, vert)
    super
  end
end
