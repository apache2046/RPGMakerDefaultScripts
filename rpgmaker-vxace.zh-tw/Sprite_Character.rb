#encoding:utf-8
#
# 地圖人物的精靈。根據 Game_Character 類的案例自動變化。
#

class Sprite_Character < Sprite_Base
  #
  # 定義案例變量
  #
  #
  attr_accessor :character
  #
  # 初始化物件
  #
  # character : Game_Character
  #
  def initialize(viewport, character = nil)
    super(viewport)
    @character = character
    @balloon_duration = 0
    update
  end
  #
  # 釋放
  #
  #
  def dispose
    end_animation
    end_balloon
    super
  end
  #
  # 更新畫面
  #
  #
  def update
    super
    update_bitmap
    update_src_rect
    update_position
    update_other
    update_balloon
    setup_new_effect
  end
  #
  # 取得指定圖塊 ID 的圖塊組
  #
  #
  def tileset_bitmap(tile_id)
    Cache.tileset($game_map.tileset.tileset_names[5 + tile_id / 256])
  end
  #
  # 更新源點陣圖（Source Bitmap）
  #
  #
  def update_bitmap
    if graphic_changed?
      @tile_id = @character.tile_id
      @character_name = @character.character_name
      @character_index = @character.character_index
      if @tile_id > 0
        set_tile_bitmap
      else
        set_character_bitmap
      end
    end
  end
  #
  # 判定圖像是否被變更
  #
  #
  def graphic_changed?
    @tile_id != @character.tile_id ||
    @character_name != @character.character_name ||
    @character_index != @character.character_index
  end
  #
  # 設定圖塊的點陣圖
  #
  #
  def set_tile_bitmap
    sx = (@tile_id / 128 % 2 * 8 + @tile_id % 8) * 32;
    sy = @tile_id % 256 / 8 % 16 * 32;
    self.bitmap = tileset_bitmap(@tile_id)
    self.src_rect.set(sx, sy, 32, 32)
    self.ox = 16
    self.oy = 32
  end
  #
  # 設定角色的點陣圖
  #
  #
  def set_character_bitmap
    self.bitmap = Cache.character(@character_name)
    sign = @character_name[/^[\!\$]./]
    if sign && sign.include?('$')
      @cw = bitmap.width / 3
      @ch = bitmap.height / 4
    else
      @cw = bitmap.width / 12
      @ch = bitmap.height / 8
    end
    self.ox = @cw / 2
    self.oy = @ch
  end
  #
  # 更新源矩形
  #
  #
  def update_src_rect
    if @tile_id == 0
      index = @character.character_index
      pattern = @character.pattern < 3 ? @character.pattern : 1
      sx = (index % 4 * 3 + pattern) * @cw
      sy = (index / 4 * 4 + (@character.direction - 2) / 2) * @ch
      self.src_rect.set(sx, sy, @cw, @ch)
    end
  end
  #
  # 更新位置
  #
  #
  def update_position
    self.x = @character.screen_x
    self.y = @character.screen_y
    self.z = @character.screen_z
  end
  #
  # 更新其他
  #
  #
  def update_other
    self.opacity = @character.opacity
    self.blend_type = @character.blend_type
    self.bush_depth = @character.bush_depth
    self.visible = !@character.transparent
  end
  #
  # 設定新的效果
  #
  #
  def setup_new_effect
    if !animation? && @character.animation_id > 0
      animation = $data_animations[@character.animation_id]
      start_animation(animation)
    end
    if !@balloon_sprite && @character.balloon_id > 0
      @balloon_id = @character.balloon_id
      start_balloon
    end
  end
  #
  # 結束動畫
  #
  #
  def end_animation
    super
    @character.animation_id = 0
  end
  #
  # 開始顯示心情圖示
  #
  #
  def start_balloon
    dispose_balloon
    @balloon_duration = 8 * balloon_speed + balloon_wait
    @balloon_sprite = ::Sprite.new(viewport)
    @balloon_sprite.bitmap = Cache.system("Balloon")
    @balloon_sprite.ox = 16
    @balloon_sprite.oy = 32
    update_balloon
  end
  #
  # 釋放心情圖示
  #
  #
  def dispose_balloon
    if @balloon_sprite
      @balloon_sprite.dispose
      @balloon_sprite = nil
    end
  end
  #
  # 更新心情圖示
  #
  #
  def update_balloon
    if @balloon_duration > 0
      @balloon_duration -= 1
      if @balloon_duration > 0
        @balloon_sprite.x = x
        @balloon_sprite.y = y - height
        @balloon_sprite.z = z + 200
        sx = balloon_frame_index * 32
        sy = (@balloon_id - 1) * 32
        @balloon_sprite.src_rect.set(sx, sy, 32, 32)
      else
        end_balloon
      end
    end
  end
  #
  # 結束心情圖示的顯示
  #
  #
  def end_balloon
    dispose_balloon
    @character.balloon_id = 0
  end
  #
  # 心情圖示的顯示速度
  #
  #
  def balloon_speed
    return 8
  end
  #
  # 心情最終幀的等待時間
  #
  #
  def balloon_wait
    return 12
  end
  #
  # 心情圖示的幀編號
  #
  #
  def balloon_frame_index
    return 7 - [(@balloon_duration - balloon_wait) / balloon_speed, 0].max
  end
end
