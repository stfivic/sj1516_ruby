TEXTURES_DIR = "C:/Users/Ivan/AppData/Roaming/SketchUp/SketchUp 2016/SketchUp/Textures/"
DEFAULT_EXTERIOR_COLOR = "Peru.jpg"
DEFAULT_TEXTURE_SIZE = 50
FLOOR_PADDING = 0.1.m
FRONT_DOOR_FRAME_PADDING = 0.3.m
FRONT_DOOR_FRAME_DEPTH = 0.15.m
FRONT_DOOR_GLASS_DEPTH = 0.1.m
DOORKNOB_DEFAULT_RADIUS = 0.05.m
WINDOW_HEIGHT_FROM_FLOOR = 0.9.m
WINDOW_PADDING = 0.05.m
WINDOW_APRON_PADDING = 0.1.m
ROOF_THICKNESS = 0.25.m
ROOF_INDENT = 0.3.m

class House

  def initialize(specs)

    # convert lengths from string to float and then from m to inches
    num_specs = []
    specs[0...-5].map(&:to_f).each{|spec| num_specs.push(spec.m)}

    @width, @depth, @height, @thickness,
    @front_door_height, @front_door_width,
    @interior_door_height, @interior_door_width,
    @window_width, @window_height, @corridor_width = num_specs

    # convert other numbers from string to float
    @rooms_depth_ratio, @living_room_bathroom_depth_ratio,
    @num_stories = specs[-5..-3].map(&:to_f)

    # make boolean variables
    specs[-2] == "Yes" ? @draw_roof_flag = true : @draw_roof_flag = false
    specs[-1] == "Yes" ? @color_flag = true : @color_flag = false

    # calculate room width
    @room_width = (@width - 4 * @thickness - @corridor_width)/2
    #calculate room depths
    @rooms_depth_summed = @depth - 3 * @thickness
    @front_room_depth = @rooms_depth_summed * (@rooms_depth_ratio/(@rooms_depth_ratio + 1.0))
    @back_room_depth = @rooms_depth_summed - @front_room_depth
    @living_room_depth = @rooms_depth_summed * (@living_room_bathroom_depth_ratio/(@living_room_bathroom_depth_ratio + 1.0))
    @bathroom_depth = @rooms_depth_summed - @living_room_depth
    @roof_height = @depth/2

    # Building the model
    @model = Sketchup.active_model
    @entities = @model.active_entities
    @materials = @model.materials

  end

  def draw_rect(x0, x1, y0, y1, z0, z1)

    pts = []
    if x0 == x1
      pts[0] = [x0, y0, z0]
      pts[1] = [x0, y1, z0]
      pts[2] = [x0, y1, z1]
      pts[3] = [x0, y0, z1]
    elsif y0 == y1
      pts[0] = [x0, y0, z0]
      pts[1] = [x1, y0, z0]
      pts[2] = [x1, y0, z1]
      pts[3] = [x0, y0, z1]
    elsif z0 == z1
      pts[0] = [x0, y0, z0]
      pts[1] = [x1, y0, z0]
      pts[2] = [x1, y1, z0]
      pts[3] = [x0, y1, z0]
    else
      pts[0] = [x0, y0, z0]
      pts[1] = [x1, y0, z0]
      pts[2] = [x1, y1, z1]
      pts[3] = [x0, y1, z1]
    end
    @entities.add_face pts

  end

  def draw_front_door

    # front door hole
    frdh_face = draw_rect((@width - @front_door_width)/2 - FRONT_DOOR_FRAME_PADDING,
                          (@width - @front_door_width)/2 + @front_door_width + FRONT_DOOR_FRAME_PADDING,
                          0,
                          0,
                          FLOOR_PADDING,
                          FLOOR_PADDING + @front_door_height + FRONT_DOOR_FRAME_PADDING)
    # make hole
    frdh_face.pushpull(-@thickness)

    # front door brick frame, padding = 0.3m
    frdf_face = draw_rect((@width - @front_door_width)/2 - FRONT_DOOR_FRAME_PADDING,
                          (@width - @front_door_width)/2 + @front_door_width + FRONT_DOOR_FRAME_PADDING,
                          FRONT_DOOR_FRAME_DEPTH,
                          FRONT_DOOR_FRAME_DEPTH,
                          FLOOR_PADDING,
                          FLOOR_PADDING + @front_door_height + FRONT_DOOR_FRAME_PADDING)
    # make brick texture for the frame and apply it to both sides
    front_door_brick = @materials.add "Front Door Brick"
    front_door_brick.texture = TEXTURES_DIR + "Stone_Sandstone_Ashlar_Light.jpg"
    front_door_brick.texture.size = DEFAULT_TEXTURE_SIZE
    frdf_face.material = front_door_brick
    frdf_face.back_material = front_door_brick

    # draw wooden doors
    frd_face = draw_rect((@width - @front_door_width)/2,
                        (@width - @front_door_width)/2 + @front_door_width,
                        FRONT_DOOR_FRAME_DEPTH,
                        FRONT_DOOR_FRAME_DEPTH,
                        FLOOR_PADDING,
                        FLOOR_PADDING + @front_door_height)
    # make wooden texture for the door and apply it to both sides
    front_door_wood = @materials.add "Front Door Wood"
    front_door_wood.texture = TEXTURES_DIR + "Wood_Bamboo.jpg"
    front_door_wood.texture.size = DEFAULT_TEXTURE_SIZE
    frd_face.material = front_door_wood
    frd_face.back_material = front_door_wood
    # push slightly to front
    frd_face.pushpull(0.05.m)

    # front door glass face
    frdg_face = draw_rect((@width - @front_door_width)/2 + 0.25 * @front_door_width,
                          (@width - @front_door_width)/2 + 0.75 * @front_door_width,
                          FRONT_DOOR_GLASS_DEPTH,
                          FRONT_DOOR_GLASS_DEPTH,
                          FLOOR_PADDING + 0.15 * @front_door_height,
                          FLOOR_PADDING + 0.85 * @front_door_height)
    # make glass texture and apply it to both sides
    front_door_glass = @materials.add "Front Door Glass"
    front_door_glass.texture = TEXTURES_DIR + "Translucent_Glass_Block_Dark.jpg"
    front_door_glass.texture.size = DEFAULT_TEXTURE_SIZE
    frdg_face.material = front_door_glass
    frdg_face.back_material = front_door_glass

  end

  def draw_window(x0, x1, y0, y1, z0, z1)

    # hole for the window
    window_hole_face = draw_rect(x0, x1, y0, y1, z0, z1)
    window_hole_face.pushpull(-@thickness)

    # if the window is to be on the left side
    if x0 == x1 && x0 == 0
      # window pane face
      window_pane_face = draw_rect(x0 + @thickness - WINDOW_PADDING,
                                  x1 + @thickness - WINDOW_PADDING,
                                  y0, y1,
                                  z0, z1)
      # window glass face
      window_glass_face = draw_rect(x0 + @thickness - WINDOW_PADDING,
                                    x1 + @thickness - WINDOW_PADDING,
                                    y0 + WINDOW_PADDING,
                                    y1 - WINDOW_PADDING,
                                    z0 + WINDOW_PADDING,
                                    z1 - WINDOW_PADDING)
      window_pane_face.pushpull(-WINDOW_PADDING/2)

      # build window apron
      window_apron = draw_rect(x0, x1,
                              y0 - WINDOW_APRON_PADDING,
                              y1 + WINDOW_APRON_PADDING,
                              z0 - WINDOW_APRON_PADDING, z0)
      window_apron.pushpull(WINDOW_APRON_PADDING)
    # if the window is to be on the right side
    elsif x0 == x1 && x0 > 0
      # window pane face
      window_pane_face = draw_rect(x0 - @thickness + WINDOW_PADDING,
                                  x1 - @thickness + WINDOW_PADDING,
                                  y0, y1,
                                  z0, z1)
      # window glass face
      window_glass_face = draw_rect(x0 - @thickness + WINDOW_PADDING,
                                    x1 - @thickness + WINDOW_PADDING,
                                    y0 + WINDOW_PADDING,
                                    y1 - WINDOW_PADDING,
                                    z0 + WINDOW_PADDING,
                                    z1 - WINDOW_PADDING)
      window_pane_face.pushpull(WINDOW_PADDING/2)

      # build window apron
      window_apron = draw_rect(x0, x1,
                              y0 - WINDOW_APRON_PADDING,
                              y1 + WINDOW_APRON_PADDING,
                              z0 - WINDOW_APRON_PADDING, z0)
      window_apron.pushpull(WINDOW_APRON_PADDING)
    # if the window is to be on the front side
    elsif y0 == y1 && y0 == 0
      # window pane face
      window_pane_face = draw_rect(x0, x1,
                                  y0 + @thickness - WINDOW_PADDING,
                                  y1 + @thickness - WINDOW_PADDING,
                                  z0, z1)
      # window glass face
      window_glass_face = draw_rect(x0 + WINDOW_PADDING,
                                    x1 - WINDOW_PADDING,
                                    y0 + @thickness - WINDOW_PADDING,
                                    y1 + @thickness - WINDOW_PADDING,
                                    z0 + WINDOW_PADDING,
                                    z1 - WINDOW_PADDING)
      window_pane_face.pushpull(WINDOW_PADDING/2)

      # build window apron
      window_apron = draw_rect(x0 - WINDOW_APRON_PADDING,
                              x1 + WINDOW_APRON_PADDING,
                              y0, y1,
                              z0 - WINDOW_APRON_PADDING, z0)
      window_apron.pushpull(WINDOW_APRON_PADDING)
    # if the window is to be on the back side
    elsif y0 == y1 && y0 > 0
      # window pane face
      window_pane_face = draw_rect(x0, x1,
                                  y0 - @thickness + WINDOW_PADDING,
                                  y1 - @thickness + WINDOW_PADDING,
                                  z0, z1)
      # window glass face
      window_glass_face = draw_rect(x0 + WINDOW_PADDING,
                                    x1 - WINDOW_PADDING,
                                    y0 - @thickness + WINDOW_PADDING,
                                    y1 - @thickness + WINDOW_PADDING,
                                    z0 + WINDOW_PADDING,
                                    z1 - WINDOW_PADDING)
      window_pane_face.pushpull(-WINDOW_PADDING/2)

      # build window apron
      window_apron = draw_rect(x0 - WINDOW_APRON_PADDING,
                              x1 + WINDOW_APRON_PADDING,
                              y0, y1,
                              z0 - WINDOW_APRON_PADDING, z0)
      window_apron.pushpull(WINDOW_APRON_PADDING)
    end

    # apply glass texture
    window_glass = @materials.add "Window Glass"
    window_glass.texture = TEXTURES_DIR + "Translucent_Glass_Tinted.jpg"
    window_glass.texture.size = DEFAULT_TEXTURE_SIZE
    window_glass_face.material = window_glass
    window_glass_face.back_material = window_glass

  end

  def draw_interior_door(x, y0, y1, z0, z1)

    # drill a hole for the door
    door_hole = draw_rect(x, x, y0, y1, z0, z1)
    door_hole.pushpull(-@thickness)

    # build door
    interior_door_face = draw_rect(x, x, y0, y1, z0, z1)

    # apply wood texture
    interior_wood = @materials.add "Interior Wood"
    interior_wood.texture = TEXTURES_DIR + "Wood_Cherry_Original.jpg"
    interior_wood.texture.size = DEFAULT_TEXTURE_SIZE
    interior_door_face.material = interior_wood
    interior_door_face.back_material = interior_wood

    # draw doorknob, can't be colored due to round-off error
    doorknob_center = [x, y0 + (y1 - y0)/4.0, (z1 - z0) * 0.6]
    doorknob_radius = DOORKNOB_DEFAULT_RADIUS
    doorknob_normal = [1, 0, 0]
    knob_edges = @entities.add_circle doorknob_center, doorknob_normal, doorknob_radius

  end

  def draw_roof

    roof_front_side = draw_rect(-ROOF_INDENT, @width + ROOF_INDENT,
                                0, @depth/2,
                                @num_stories * @height,
                                @num_stories * @height + @roof_height)
    roof_back_side = draw_rect(-ROOF_INDENT, @width + ROOF_INDENT,
                                @depth/2, @depth,
                                @num_stories * @height + @roof_height,
                                @num_stories * @height)

    # make roofing texture for the roof and apply it to both sides
    roofing_tile = @materials.add "Roofing Tile"
    roofing_tile.texture = TEXTURES_DIR + "Roofing_Tile_Spanish.jpg"
    roofing_tile.texture.size = DEFAULT_TEXTURE_SIZE

    roof_front_side.material = roofing_tile
    roof_front_side.back_material = roofing_tile
    roof_back_side.material = roofing_tile
    roof_back_side.back_material = roofing_tile

    roof_front_side.pushpull(ROOF_THICKNESS)
    roof_back_side.pushpull(ROOF_THICKNESS, true)

    # draw triangle shaped parts of wall between roof and story walls
    tr_pts1 = []
    tr_pts2 = []

    tr_pts1[0] = [0, 0, @num_stories * @height]
    tr_pts1[1] = [0, @depth/2, @num_stories * @height + @roof_height]
    tr_pts1[2] = [0, @depth, @num_stories * @height]
    tr1 = @entities.add_face tr_pts1

    tr_pts2[0] = [@width, 0, @num_stories * @height]
    tr_pts2[1] = [@width, @depth/2, @num_stories * @height + @roof_height]
    tr_pts2[2] = [@width, @depth, @num_stories * @height]
    tr2 = @entities.add_face tr_pts2

    # color triangle shaped parts of wall if needed
    if @color_flag
      # make texture for the extern wall faces and apply it
      exterior_color = @materials.add "Exterior Color"
      exterior_color.texture = TEXTURES_DIR + DEFAULT_EXTERIOR_COLOR
      exterior_color.texture.size = DEFAULT_TEXTURE_SIZE
      tr1.material = exterior_color
      tr2.material = exterior_color
    end

  end

  def draw_base_story

    # ground face
    grnd_face = draw_rect(0, @width, 0, @depth, @height, @height)
    # pull ground face up to height
    grnd_face.pushpull(-@height)

    # color the outer walls if the flag is up, determine right faces
    if @color_flag
      # find all faces connected to grnd_face
      connected = grnd_face.all_connected
      # find those that are horizontal
      connected.each do |entity|
        if entity.instance_of? Sketchup::Face
          z_array = []
          entity.vertices.each do |vertex|
            z = vertex.position[2]
            z_array.push(z)
          end
          # if the face is horizontal and higher than the ground then
          # it should not be painted (because it paints the inside walls then too)
          next if z_array.all? {|z| z == z_array[0]} && z_array[0] > 0
          # make texture for the extern wall faces and apply it
          exterior_color = @materials.add "Exterior Color"
          exterior_color.texture = TEXTURES_DIR + DEFAULT_EXTERIOR_COLOR
          exterior_color.texture.size = DEFAULT_TEXTURE_SIZE
          entity.material = exterior_color
        end
      end
    end

    # corridor face
    corr_face = draw_rect(@room_width + 2 * @thickness,
                          @room_width + 2 * @thickness + @corridor_width,
                          @thickness,
                          @depth - @thickness,
                          @height,
                          @height)
    # push corridor face to ground
    corr_face.pushpull(-@height + FLOOR_PADDING)

    # front room face
    frp_face = draw_rect(@thickness,
                        @thickness + @room_width,
                        @thickness,
                        @thickness + @front_room_depth,
                        @height,
                        @height)
    # push front room face to ground
    frp_face.pushpull(- @height + FLOOR_PADDING)

    # back room face
    brp_face = draw_rect(@thickness,
                        @thickness + @room_width,
                        2 * @thickness + @front_room_depth,
                        2 * @thickness + @front_room_depth + @back_room_depth,
                        @height,
                        @height)
    # push back room face to ground
    brp_face.pushpull(- @height + FLOOR_PADDING)

    # living room face
    lr_face = draw_rect(3 * @thickness + @room_width + @corridor_width,
                        3 * @thickness + 2 * @room_width + @corridor_width,
                        @thickness,
                        @thickness + @living_room_depth,
                        @height,
                        @height)
    # push living room face to ground
    lr_face.pushpull(- @height + FLOOR_PADDING)

    # bathroom room face
    br_face = draw_rect(3 * @thickness + @room_width + @corridor_width,
                        3 * @thickness + 2 * @room_width + @corridor_width,
                        2 * @thickness + @living_room_depth,
                        2 * @thickness + @living_room_depth + @bathroom_depth,
                        @height,
                        @height)
    # push bathroom room face to ground
    br_face.pushpull(- @height + FLOOR_PADDING)

    # draw a couple of windows, first two on the front
    draw_window(@room_width/2 + @thickness - @window_width/2,
                @room_width/2 + @thickness + @window_width/2,
                0,0,
                WINDOW_HEIGHT_FROM_FLOOR,
                WINDOW_HEIGHT_FROM_FLOOR + @window_height)
    draw_window(@width - @thickness - @room_width/2 - @window_width/2,
                @width - @thickness - @room_width/2 + @window_width/2,
                0,0,
                WINDOW_HEIGHT_FROM_FLOOR,
                WINDOW_HEIGHT_FROM_FLOOR + @window_height)
    # on the right side
    draw_window(@width,
                @width,
                @thickness + @living_room_depth/2 - @window_width/2,
                @thickness + @living_room_depth/2 + @window_width/2,
                WINDOW_HEIGHT_FROM_FLOOR,
                WINDOW_HEIGHT_FROM_FLOOR + @window_height)
    # on the left side
    draw_window(0,
                0,
                @thickness + @front_room_depth/2 - @window_width/2,
                @thickness + @front_room_depth/2 + @window_width/2,
                WINDOW_HEIGHT_FROM_FLOOR,
                WINDOW_HEIGHT_FROM_FLOOR + @window_height)
    # on the backroom
    draw_window(@room_width/2 + @thickness - @window_width/2,
                @room_width/2 + @thickness + @window_width/2,
                @depth, @depth,
                WINDOW_HEIGHT_FROM_FLOOR,
                WINDOW_HEIGHT_FROM_FLOOR + @window_height)
    # on the corridor back
    draw_window(@width/2 - @window_width/2,
                @width/2 + @window_width/2,
                @depth, @depth,
                WINDOW_HEIGHT_FROM_FLOOR,
                WINDOW_HEIGHT_FROM_FLOOR + @window_height)

    # draw doors on front room
    draw_interior_door(@room_width + 2 * @thickness,
                        @thickness + @front_room_depth/2 - @interior_door_width/2,
                        @thickness + @front_room_depth/2 + @interior_door_width/2,
                        FLOOR_PADDING,
                        FLOOR_PADDING + @interior_door_height)
    # draw doors on back room
    draw_interior_door(@room_width + 2 * @thickness,
                        2 * @thickness + @front_room_depth + @back_room_depth/2 - @interior_door_width/2,
                        2 * @thickness + @front_room_depth + @back_room_depth/2 + @interior_door_width/2,
                        FLOOR_PADDING,
                        FLOOR_PADDING + @interior_door_height)
    # draw doors on living room
    draw_interior_door(@room_width + 2 * @thickness + @corridor_width,
                        @thickness + @living_room_depth/2 - @interior_door_width/2,
                        @thickness + @living_room_depth/2 + @interior_door_width/2,
                        FLOOR_PADDING,
                        FLOOR_PADDING + @interior_door_height)
    # draw doors on bathroom
    draw_interior_door(@room_width + 2 * @thickness + @corridor_width,
                        2 * @thickness + @living_room_depth + @bathroom_depth/2 - @interior_door_width/2,
                        2 * @thickness + @living_room_depth + @bathroom_depth/2 + @interior_door_width/2,
                        FLOOR_PADDING,
                        FLOOR_PADDING + @interior_door_height)

  end

  def draw

    # draw base story, everything except front door
    draw_base_story

    # group the elements of the base story for copying
    story = @entities.add_group(@entities.to_a)
    # make a copy of the base story and move it on top of existing stories
    for i in 0...(@num_stories - 1)
      new_story = story.copy
      moving_point = Geom::Point3d.new -WINDOW_APRON_PADDING, -WINDOW_APRON_PADDING, (i + 1) * @height
      t = Geom::Transformation.new moving_point
      new_story = new_story.move! t
      new_story.explode
      # add a window to all additional stories in place of front door
      draw_window(@width/2 - @window_width/2,
                  @width/2 + @window_width/2,
                  0, 0,
                  WINDOW_HEIGHT_FROM_FLOOR + (i+1) * @height,
                  WINDOW_HEIGHT_FROM_FLOOR + (i+1) * @height + @window_height)
    end

    #explode the base story so front doors can be added
    story.explode

    # draw front door on base story
    draw_front_door
    # draw roof if flag is up
    draw_roof if @draw_roof_flag

  end

end

# Getting parameters
prompts = ["Width [m]  ",
          "Depth [m]  ",
          "Story height [m] ",
          "Wall thickness [m] ",
          "Front door height [m]  ",
          "Front door width [m]  ",
          "Interior door height [m]",
          "Interior door width [m] ",
          "Window width [m] ",
          "Window height [m]  ",
          "Corridor width [m] ",
          "Front room to back room depth ratio  ",
          "Living room to bathroom depth ratio  ",
          "Number of stories  ",
          "Draw the roof?",
          "Paint the house?"]
defaults = ["20", "10", "3", "0.35", "2", "1.5", "1.7", "1", "0.9", "1.3", "3", "1", "2.5", "2", "Yes", "Yes"]
list = ["", "", "", "", "", "", "", "", "", "", "", "", "", "", "Yes|No", "Yes|No"]
specs = UI.inputbox(prompts, defaults, list, "Model Specifications")

house = House.new(specs)
house.draw
