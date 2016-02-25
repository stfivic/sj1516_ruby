DEFAULT_TEXTURE_SIZE = 50
FLOOR_PADDING = 0.1.m
FRONT_DOOR_FRAME_PADDING = 0.3.m
DOORKNOB_DEFAULT_RADIUS = 0.05.m
WINDOW_HEIGHT_FROM_FLOOR = 0.9.m
ROOF_THICKNESS = 0.25.m
TEXTURES_DIR = "C:/Users/Ivan/AppData/Roaming/SketchUp/SketchUp 2016/SketchUp/Custom Textures/"
DEFAULT_EXTERIOR_COLOR = "Peru.jpg"

def draw_rect(entities, x0, x1, y0, y1, z0, z1)

  pts = []
  pts[0] = [x0, y0, z0]
  pts[1] = [x1, y0, z0]
  pts[2] = [x1, y1, z1]
  pts[3] = [x0, y1, z1]
  entities.add_face pts
end

def draw_base_story(model, width, depth, height, thickness, corridor_width,
                rooms_depth_ratio, living_room_bathroom_depth_ratio,
                room_width, front_room_depth, back_room_depth,
                living_room_depth, bathroom_depth, color_flag)

  entities = model.active_entities
  materials = model.materials
  # ground face
  grnd_face = draw_rect(entities, 0, width.m, 0, depth.m, height.m, height.m)
  # pull ground face up to height
  grnd_face.pushpull(-height.m)

  # color the outer walls if the flag is up, determine right faces
  if color_flag
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
        exterior_color = materials.add "Exterior Color"
        exterior_color.texture = TEXTURES_DIR + DEFAULT_EXTERIOR_COLOR
        exterior_color.texture.size = DEFAULT_TEXTURE_SIZE
        entity.material = exterior_color
      end
    end
  end

  # corridor face
  corr_face = draw_rect(entities, room_width.m + 2 * thickness.m,
                                    room_width.m + 2 * thickness.m + corridor_width.m,
                                    thickness.m,
                                    depth.m - thickness.m,
                                    height.m,
                                    height.m)
  # push corridor face to ground
  corr_face.pushpull(- height.m + FLOOR_PADDING)

  # front room face
  frp_face = draw_rect(entities, thickness.m,
                                  thickness.m + room_width.m,
                                  thickness.m,
                                  thickness.m + front_room_depth.m,
                                  height.m,
                                  height.m)
  # push front room face to ground
  frp_face.pushpull(- height.m + FLOOR_PADDING)

  # back room face
  brp_face = draw_rect(entities,
                                  thickness.m,
                                  thickness.m + room_width.m,
                                  2 * thickness.m + front_room_depth.m,
                                  2 * thickness.m + front_room_depth.m + back_room_depth.m,
                                  height.m,
                                  height.m)
  # push back room face to ground
  brp_face.pushpull(- height.m + FLOOR_PADDING)



  # living room face
  lr_face = draw_rect(entities,
                                  3 * thickness.m + room_width.m + corridor_width.m,
                                  3 * thickness.m + 2 * room_width.m + corridor_width.m,
                                  thickness.m,
                                  thickness.m + living_room_depth.m,
                                  height.m,
                                  height.m)
  # push living room face to ground
  lr_face.pushpull(- height.m + FLOOR_PADDING)

  # bathroom room face
  br_face = draw_rect(entities,
                                  3 * thickness.m + room_width.m + corridor_width.m,
                                  3 * thickness.m + 2 * room_width.m + corridor_width.m,
                                  2 * thickness.m + living_room_depth.m,
                                  2 * thickness.m + living_room_depth.m + bathroom_depth.m,
                                  height.m,
                                  height.m)
  # push bathroom room face to ground
  br_face.pushpull(- height.m + FLOOR_PADDING)
end

def draw_front_door(model, width, front_door_width, front_door_height, thickness)

  entities = model.active_entities
  materials = model.materials

  # front door hole
  frdh_face = draw_rect(entities,
                          (width - front_door_width)/2 - FRONT_DOOR_FRAME_PADDING,
                          (width - front_door_width)/2 + front_door_width + FRONT_DOOR_FRAME_PADDING,
                          0,
                          0,
                          FLOOR_PADDING,
                          FLOOR_PADDING + front_door_height + FRONT_DOOR_FRAME_PADDING)
  # make hole
  frdh_face.pushpull(-thickness)

  # front door brick frame, padding = 0.2m
  frdf_face = draw_rect(entities,
                          (width - front_door_width)/2 - FRONT_DOOR_FRAME_PADDING,
                          (width - front_door_width)/2 + front_door_width + FRONT_DOOR_FRAME_PADDING,
                          0.15.m,
                          0.15.m,
                          FLOOR_PADDING,
                          FLOOR_PADDING + front_door_height + FRONT_DOOR_FRAME_PADDING)
  # make brick texture for the frame and apply it to both sides
  front_door_brick = materials.add "Front Door Brick"
  front_door_brick.texture = TEXTURES_DIR + "Stone_Sandstone_Ashlar_Light.jpg"
  front_door_brick.texture.size = DEFAULT_TEXTURE_SIZE
  frdf_face.material = front_door_brick
  frdf_face.back_material = front_door_brick

  # draw wooden doors
  frd_face = draw_rect(entities,
                          (width - front_door_width)/2,
                          (width - front_door_width)/2 + front_door_width,
                          0.15.m,
                          0.15.m,
                          FLOOR_PADDING,
                          FLOOR_PADDING + front_door_height)
  # make wooden texture for the door and apply it to both sides
  front_door_wood = materials.add "Front Door Wood"
  front_door_wood.texture = TEXTURES_DIR + "Wood_Bamboo.jpg"
  front_door_wood.texture.size = DEFAULT_TEXTURE_SIZE
  frd_face.material = front_door_wood
  frd_face.back_material = front_door_wood

  # push slightly to front
  frd_face.pushpull(0.05.m)

  # front door glass face
  frdg_face = draw_rect(entities,
                          (width - front_door_width)/2 + 0.25 * front_door_width,
                          (width - front_door_width)/2 + 0.75 * front_door_width,
                          0.10.m,
                          0.10.m,
                          FLOOR_PADDING + 0.15 * front_door_height,
                          FLOOR_PADDING + 0.85 * front_door_height)
  # make glass texture and apply it to both sides
  front_door_glass = materials.add "Front Door Glass"
  front_door_glass.texture = TEXTURES_DIR + "Translucent_Glass_Block_Dark.jpg"
  front_door_glass.texture.size = DEFAULT_TEXTURE_SIZE
  frdg_face.material = front_door_glass
  frdg_face.back_material = front_door_glass
end

def draw_window(model, x0, x1, y0, y1, z0, z1, thickness)

  entities = model.active_entities
  materials = model.materials

  # hole for the window
  window_hole_face = draw_rect(entities, x0, x1, y0, y1, z0, z1)
  window_hole_face.pushpull(-thickness)

  # if the window is to be on the left side
  if x0 == x1 && x0 == 0
    # window pane face
    window_pane_face = draw_rect(entities, x0 + thickness - 0.1.m, x1 + thickness - 0.1.m, y0, y1, z0, z1)
    # window glass face
    window_glass_face = draw_rect(entities, x0  + thickness - 0.1.m, x1 + thickness - 0.1.m, y0 + 0.1.m, y1 - 0.1.m, z0 + 0.1.m, z1 - 0.1.m)
    window_pane_face.pushpull(-0.05.m)

    # build window apron
    window_apron = draw_rect(entities, x0, x1, y0 - 0.1.m, y1 + 0.1.m, z0 - 0.1.m, z0)
    window_apron.pushpull(0.1.m)
  # if the window is to be on the right side
  elsif x0 == x1 && x0 > 0
    # window pane face
    window_pane_face = draw_rect(entities, x0 - thickness + 0.1.m, x1 - thickness + 0.1.m, y0, y1, z0, z1)
    # window glass face
    window_glass_face = draw_rect(entities, x0  - thickness + 0.1.m, x1 - thickness + 0.1.m, y0 + 0.1.m, y1 - 0.1.m, z0 + 0.1.m, z1 - 0.1.m)
    window_pane_face.pushpull(0.05.m)

    # build window apron
    window_apron = draw_rect(entities, x0, x1, y0 - 0.1.m, y1 + 0.1.m, z0 - 0.1.m, z0)
    window_apron.pushpull(0.1.m)
  # if the window is to be on the front side
  elsif y0 == y1 && y0 == 0
    # window pane face
    window_pane_face = draw_rect(entities, x0, x1, y0 + thickness - 0.1.m, y1 + thickness - 0.1.m, z0, z1)
    # window glass face
    window_glass_face = draw_rect(entities, x0 + 0.1.m, x1 - 0.1.m, y0 + thickness - 0.1.m, y1 + thickness - 0.1.m, z0 + 0.1.m, z1 - 0.1.m)
    window_pane_face.pushpull(0.05.m)

    # build window apron
    window_apron = draw_rect(entities, x0 - 0.1.m, x1 + 0.1.m, y0, y1, z0 - 0.1.m, z0)
    window_apron.pushpull(0.1.m)
  # if the window is to be on the back side
  elsif y0 == y1 && y0 > 0
    # window pane face
    window_pane_face = draw_rect(entities, x0, x1, y0 - thickness + 0.1.m, y1 - thickness + 0.1.m, z0, z1)
    # window glass face
    window_glass_face = draw_rect(entities, x0 + 0.1.m, x1 - 0.1.m, y0 - thickness + 0.1.m, y1 - thickness + 0.1.m, z0 + 0.1.m, z1 - 0.1.m)
    window_pane_face.pushpull(-0.05.m)

    # build window apron
    window_apron = draw_rect(entities, x0 - 0.1.m, x1 + 0.1.m, y0, y1, z0 - 0.1.m, z0)
    window_apron.pushpull(0.1.m)
  end

  # apply glass texture
  window_glass = materials.add "Window Glass"
  window_glass.texture = TEXTURES_DIR + "Translucent_Glass_Tinted.jpg"
  window_glass.texture.size = DEFAULT_TEXTURE_SIZE
  window_glass_face.material = window_glass
  window_glass_face.back_material = window_glass
end

def draw_interior_door(model, x, y0, y1, z0, z1, width, thickness)

  entities = model.active_entities
  materials = model.materials

  # drill a hole for the door
  door_hole = draw_rect(entities, x, x, y0, y1, z0, z1)
  door_hole.pushpull(-thickness)

  # build door
  interior_door_face = draw_rect(entities, x, x, y0, y1, z0, z1)

  # apply wood texture
  interior_wood = materials.add "Interior Wood"
  interior_wood.texture = TEXTURES_DIR + "Wood_Cherry_Original.jpg"
  interior_wood.texture.size = DEFAULT_TEXTURE_SIZE
  interior_door_face.material = interior_wood
  interior_door_face.back_material = interior_wood

  # draw doorknob, can't be colored due to round-off error
  doorknob_center = [x, y0 + (y1 - y0)/4.0, (z1 - z0) * 0.6]
  doorknob_radius = DOORKNOB_DEFAULT_RADIUS
  doorknob_normal = [1, 0, 0]
  knob_edges = entities.add_circle doorknob_center, doorknob_normal, doorknob_radius
end

def draw_roof(model, width, depth, height, num_stories, roof_height, color_flag)

  entities = model.active_entities
  materials = model.materials

  roof_front_side = draw_rect(entities, 0, width.m, 0, depth.m/2, num_stories * height.m, num_stories * height.m + roof_height.m)
  roof_back_side = draw_rect(entities, 0, width.m, depth.m/2, depth.m, num_stories * height.m + roof_height.m, num_stories * height.m)

  # make roofing texture for the roof and apply it to both sides
  roofing_tile = materials.add "Roofing Tile"
  roofing_tile.texture = TEXTURES_DIR + "Roofing_Tile_Spanish.jpg"
  roofing_tile.texture.size = DEFAULT_TEXTURE_SIZE

  roof_front_side.material = roofing_tile
  roof_back_side.material = roofing_tile

  roof_front_side.pushpull(ROOF_THICKNESS)
  roof_back_side.pushpull(ROOF_THICKNESS)

  tr_pts1 = []
  tr_pts2 = []

  tr_pts1[0] = [0, 0, num_stories * height.m]
  tr_pts1[1] = [0, depth.m/2, num_stories * height.m + roof_height.m]
  tr_pts1[2] = [0, depth.m, num_stories * (height.m)]
  tr1 = entities.add_face tr_pts1

  tr_pts2[0] = [width.m, 0, num_stories * height.m]
  tr_pts2[1] = [width.m, depth.m/2, num_stories * height.m + roof_height.m]
  tr_pts2[2] = [width.m, depth.m, num_stories * height.m]
  tr2 = entities.add_face tr_pts2

  # color triangle shaped parts of wall if needed
  if color_flag
    # make texture for the extern wall faces and apply it
    exterior_color = materials.add "Exterior Color"
    exterior_color.texture = TEXTURES_DIR + DEFAULT_EXTERIOR_COLOR
    exterior_color.texture.size = DEFAULT_TEXTURE_SIZE
    tr1.material = exterior_color
    tr2.material = exterior_color
  end
end

def draw_additional_stories(model, num_stories, height)

  entities = model.active_entities
  story=entities.add_group(entities.to_a)
  # make a copy of the base story and move it on top of existing stories
  for i in 0...(num_stories - 1)
    new_story = story.copy
    moving_point = Geom::Point3d.new -0.1.m, -0.1.m, (i + 1) * (height) #  0, 0, (i + 1) * (height.m) ??
    t = Geom::Transformation.new moving_point
    new_story = new_story.move! t
  end
  #explode the base story so front doors can be added
  story.explode

end
# Getting parameters
prompts = ["Width [m]  ",
          "Depth [m]  ",
          "Story height [m] ",
          "Number of stories  ",
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
          "Draw the roof?",
          "Paint the house?"]
defaults = ["20", "10", "3", "1", "0.35", "2", "1.5", "1.7", "1", "0.9", "1.3", "3", "1", "2.5", "Yes", "Yes"]
list = ["", "", "", "", "", "", "", "", "", "", "", "", "", "", "Yes|No", "Yes|No"]
specs = UI.inputbox(prompts, defaults, list, "Model Specifications")

width, depth, height, num_stories, thickness,
front_door_height, front_door_width,
interior_door_height, interior_door_width,
window_width, window_height, corridor_width,
rooms_depth_ratio, living_room_bathroom_depth_ratio = specs[0...-2].map(&:to_f)

draw_roof_flag = specs[-2]
draw_roof_flag == "Yes" ? draw_roof_flag = true : draw_roof_flag = false
color_flag = specs[-1]
color_flag == "Yes" ? color_flag = true : color_flag = false

# calculate room width
room_width = (width - 4 * thickness - corridor_width)/2
#calculate room depths
rooms_depth_summed = depth - 3 * thickness
front_room_depth = rooms_depth_summed * (rooms_depth_ratio/(rooms_depth_ratio + 1.0))
back_room_depth = rooms_depth_summed - front_room_depth
living_room_depth = rooms_depth_summed * (living_room_bathroom_depth_ratio/(living_room_bathroom_depth_ratio + 1.0))
bathroom_depth = rooms_depth_summed - living_room_depth

# Building the model
model = Sketchup.active_model
entities = model.active_entities
materials = model.materials

draw_base_story(model, width, depth, height, thickness, corridor_width,
                rooms_depth_ratio, living_room_bathroom_depth_ratio,
                room_width, front_room_depth, back_room_depth,
                living_room_depth, bathroom_depth, color_flag)

# draw a couple of windows, first two on the front
draw_window(model,
            (room_width/2).m + thickness.m - window_width.m/2,
            (room_width/2).m + thickness.m + window_width.m/2,
            0,0,
            WINDOW_HEIGHT_FROM_FLOOR,
            WINDOW_HEIGHT_FROM_FLOOR + window_height.m,
            thickness.m)
draw_window(model,
            width.m - thickness.m - (room_width/2).m - window_width.m/2,
            width.m - thickness.m - (room_width/2).m + window_width.m/2,
            0,0,
            WINDOW_HEIGHT_FROM_FLOOR,
            WINDOW_HEIGHT_FROM_FLOOR + window_height.m,
            thickness.m)
# on the right side
draw_window(model,
            width.m,
            width.m,
            thickness.m + living_room_depth.m/2 - window_width.m/2,
            thickness.m + living_room_depth.m/2 + window_width.m/2,
            WINDOW_HEIGHT_FROM_FLOOR,
            WINDOW_HEIGHT_FROM_FLOOR + window_height.m,
            thickness.m)
# on the left side
draw_window(model,
            0,
            0,
            thickness.m + front_room_depth.m/2 - window_width.m/2,
            thickness.m + front_room_depth.m/2 + window_width.m/2,
            WINDOW_HEIGHT_FROM_FLOOR,
            WINDOW_HEIGHT_FROM_FLOOR + window_height.m,
            thickness.m)
# on the backroom
draw_window(model,
            (room_width/2).m + thickness.m - window_width.m/2,
            (room_width/2).m + thickness.m + window_width.m/2,
            depth.m, depth.m,
            WINDOW_HEIGHT_FROM_FLOOR,
            WINDOW_HEIGHT_FROM_FLOOR + window_height.m,
            thickness.m)

# on the corridor back
draw_window(model,
            width.m/2 - window_width.m/2,
            width.m/2 + window_width.m/2,
            depth.m, depth.m,
            WINDOW_HEIGHT_FROM_FLOOR,
            WINDOW_HEIGHT_FROM_FLOOR + window_height.m,
            thickness.m)

# draw doors on front room
draw_interior_door(model,
                    room_width.m + 2 * thickness.m,
                    thickness.m + front_room_depth.m/2 - interior_door_width.m/2,
                    thickness.m + front_room_depth.m/2 + interior_door_width.m/2,
                    FLOOR_PADDING,
                    FLOOR_PADDING + interior_door_height.m,
                    width.m,
                    thickness.m)
# draw doors on back room
draw_interior_door(model,
                    room_width.m + 2 * thickness.m,
                    2 * thickness.m + front_room_depth.m + back_room_depth.m/2 - interior_door_width.m/2,
                    2 * thickness.m + front_room_depth.m + back_room_depth.m/2 + interior_door_width.m/2,
                    FLOOR_PADDING,
                    FLOOR_PADDING + interior_door_height.m,
                    width.m,
                    thickness.m)
# draw doors on living room
draw_interior_door(model,
                    room_width.m + 2 * thickness.m + corridor_width.m,
                    thickness.m + living_room_depth.m/2 - interior_door_width.m/2,
                    thickness.m + living_room_depth.m/2 + interior_door_width.m/2,
                    FLOOR_PADDING,
                    FLOOR_PADDING + interior_door_height.m,
                    width.m,
                    thickness.m)
# draw doors on bathroom
draw_interior_door(model,
                    room_width.m + 2 * thickness.m + corridor_width.m,
                    2 * thickness.m + living_room_depth.m + bathroom_depth.m/2 - interior_door_width.m/2,
                    2 * thickness.m + living_room_depth.m + bathroom_depth.m/2 + interior_door_width.m/2,
                    FLOOR_PADDING,
                    FLOOR_PADDING + interior_door_height.m,
                    width.m,
                    thickness.m)

draw_additional_stories(model, num_stories, height.m)
draw_front_door(model, width.m, front_door_width.m, front_door_height.m, thickness.m)
draw_roof(model, width, depth, height, num_stories, depth/2, color_flag) if draw_roof_flag
