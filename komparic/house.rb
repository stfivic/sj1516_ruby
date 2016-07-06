require 'sketchup.rb'
TEXTURES_DIR = "C:/Users/Bepo/AppData/Roaming/SketchUp/SketchUp 2016/SketchUp/Textures/"

class House
	
	attr_accessor :model, :entities

	def initialize(lenght, width, height, garage, roof, floor_number)
		@model = Sketchup.active_model
		@entities = model.entities
		@materials = model.materials
		@lenght = lenght
		@width = width
		@story_height = height
		@garage_flag = garage
		@roof = roof
		@wall_width = 0.2.m
		@floor_height = 0.2.m
		@door_width = 1.0.m
		@door_height = 2.0.m
		@window_width = 0.75.m
		@window_height = 1.0.m
		@window_padding = 0.05.m
		@window_elevation = 1.0.m
		@large_window_width = 4.0.m
		@large_window_height = 2.0.m
		@door_padding = 0.05.m
		@floor_number = floor_number
		@total_height = 0
		@roof_width = 0.2.m
		@mat_out_wall = @materials.add("outside_wall")
		@mat_out_wall.texture = TEXTURES_DIR + "outside_wall.jpg"
		@mat_out_wall.texture.size = 30
		@mat_int_wall = @materials.add("interior_wall")
		@mat_int_wall.color = "#8aeaff"
		@mat_floor_tile = @materials.add("floor_tile")
		@mat_floor_tile.texture = TEXTURES_DIR + "floor_tile.jpg"
		@mat_floor_tile.texture.size = 30
		@padding_mat = @materials.add("m_door")
		@padding_mat.texture = TEXTURES_DIR + "m_door.jpg"
		@padding_mat.texture.size = 30
		@mat_roof = @materials.add("roof")
		@mat_roof.texture = TEXTURES_DIR + "kupe.jpg"
		@mat_roof.texture.size = 30
		
	end
	
	def draw()
		@height = @story_height
		
		draw_floor
			
		floor = @entities.add_group(@entities.to_a)
    
		for i in 1...(@floor_number)
		  next_floor = floor.copy
		  move_to = Geom::Point3d.new 0, 0, (i) * @height
		  t = Geom::Transformation.new move_to
		  next_floor = next_floor.transform! t
		  next_floor.explode
		  draw_window @lenght/2-@window_width/2, @lenght/2+@window_width/2, 0, 0, @window_elevation + @height*(i), @window_elevation + @window_height + @height*(i)
		end
		
		
		floor.explode
		
		draw_door @lenght/2-@door_width/2, @lenght/2+@door_width/2, 0, 0, @floor_height, @door_height
		draw_door @lenght-@wall_width, @lenght-@wall_width, @width/3+@wall_width, @width/3+@wall_width+@door_width, @floor_height, @door_height 
		
		if @garage_flag
			g = draw_garage
		end		
			
		if @roof 
			draw_roof
		end		
		
	end
	
	def draw_roof()
		  draw_roof_rec(-0.3.m, @lenght+0.3.m, @lenght/6*5, @lenght/6,
							-0.3.m, @width/2, @floor_number*@height,
							@floor_number*@height + 2.0.m)
							
		  draw_roof_rec(-0.3.m, @lenght+0.3.m, @lenght/6*5, @lenght/6,
						 @width + 0.3.m, @width/2, 
						 @floor_number*@height, @floor_number*@height + 2.0.m)		

		  draw_roof_side(-0.3.m, @lenght/6,
						 -0.3.m, @width+0.3.m, @width/2,
						 @floor_number*@height, @floor_number*@height + 2.0.m)	

		  draw_roof_side(@lenght + 0.3.m, @lenght/6*5,
						 -0.3.m, @width+0.3.m, @width/2,
						 @floor_number*@height, @floor_number*@height + 2.0.m)					
		
	end
	
	def draw_roof_rec(x11,x12, x21, x22, y1, y2, z1, z2)
		  pt1 = [x11, y1, z1]
		  pt2 = [x12, y1, z1]
		  pt3 = [x21, y2, z2]
		  pt4 = [x22, y2, z2]
		  
		  roof_side = @entities.add_face pt1, pt2, pt3, pt4
		  roof_side.pushpull -@roof_width
		  roof_side.material = @mat_roof
	end
	
	def draw_roof_side(x1, x2, y11, y12, y2, z1, z2)
	      pt1 = [x1, y11, z1]
		  pt2 = [x1, y12, z1]
		  pt3 = [x2, y2, z2]
		  
		  roof_side = @entities.add_face pt1, pt2, pt3
		  roof_side.pushpull -@roof_width
		  roof_side.material = @mat_roof
	end
	
	def draw_floor()
		floor = draw_space 0, @lenght, 0, @width, @height, @height
		floor.back_material =  @mat_out_wall
		floor.pushpull -@height
		
		
		#color_surface(floor, "floor.jpg", 0, false)
		#color_surface(floor, "inside_wall.jpg", 2)
		#color_surface(floor, "outside_wall.jpg", 1, false)

		corridor = draw_space @lenght/2-0.75.m, @lenght/2+0.75.m, @wall_width, (@width/2)-@wall_width, @height, @height
		corridor.material = @mat_int_wall
		corridor.pushpull (-@height+@floor_height)
		floor = draw_space @lenght/2-0.75.m, @lenght/2+0.75.m, @wall_width, (@width/2)-@wall_width, @floor_height, @floor_height
		floor.material = @mat_floor_tile
		
		
		draw_room @lenght/2+0.75.m + @wall_width, @lenght-@wall_width, @wall_width, (@width/3)-@wall_width, @height, @height
		draw_room @lenght/2+0.75.m + @wall_width, @lenght-@wall_width, (@width/3), @width-@wall_width, @height, @height
		draw_room @wall_width, @lenght/2+0.75.m, (@width/2), @width-@wall_width, @height, @height
		draw_room @wall_width, @lenght/2-0.75.m-@wall_width, @wall_width, @width/2, @height, @height

		draw_door @lenght/2+0.75.m, @lenght/2+0.75.m, @width/3/2-0.5.m, @width/3/2+0.5.m, @floor_height, @door_height
		draw_door @lenght/2+0.75.m+@wall_width*2, @lenght/2+0.75.m + @wall_width*2 + @door_width , @width/3-@wall_width, @width/3-@wall_width, @floor_height, @door_height
		draw_door @lenght/2-0.75.m- @wall_width, @lenght/2-0.75.m-@wall_width, @width/2-@wall_width*2, @width/2-@wall_width*2-@door_width, @floor_height, @door_height
		draw_door @lenght/2+0.75.m, @lenght/2+0.75.m, @width-@wall_width*2, @width-@wall_width*2-@door_width, @floor_height, @door_height
		#draw_door @lenght-@wall_width, @lenght-@wall_width, @width/3+@wall_width, @width/3+@wall_width+@door_width, @floor_height, @door_height 
		
		if (@width/2-@wall_width)-(@width/3+@wall_width)>1.0.m
			draw_door @lenght/2+0.75.m, @lenght/2+0.75.m, @width/2-@wall_width*2, @width/2-@wall_width*2-@door_width, @floor_height, @door_height
		end
		
		draw_window 0, 0, @width/4 - @window_width/2, @width/4 + @window_width/2, @window_elevation, @window_elevation + @window_height
		draw_window 0, 0, @width/4*3 - @window_width/2, @width/4*3 + @window_width/2, @window_elevation, @window_elevation + @window_height
		draw_window @lenght/4-@window_width/2, @lenght/4+@window_width/2, 0, 0, @window_elevation, @window_elevation + @window_height
		draw_window @lenght/4*3-@window_width/2, @lenght/4*3+@window_width/2, 0, 0, @window_elevation, @window_elevation + @window_height
		draw_window @lenght/4*3-@window_width, @lenght/4*3+@window_width, @width, @width, @window_elevation, @window_elevation + @window_height
		draw_window @lenght/4-@window_width, @lenght/4+@window_width, @width, @width, @window_elevation, @window_elevation + @window_height
		
	end
	
	def color_surface(face, texture_name, type, garage)
		entities = face.all_connected
      
		entities.each do |entity|
			if entity.instance_of? Sketchup::Face
			  zArray = []
			  yArray = []
			  xArray = []
			  entity.vertices.each do |vertex|
				x = vertex.position[0]
				y = vertex.position[1]
				z = vertex.position[2]
				xArray.push(x)
				yArray.push(y)
				zArray.push(z)
				
			  end
			 if garage
				next if xArray.all? {|x| x == @lenght && type == 1}
			 end
				
			 next if (zArray.all? {|z| z == zArray[0]} && type == 1 && zArray[0] > 0) #|| 
					 #(zArray.all? {|z| z == zArray[0]} && type == 2 && zArray[0] < 0) ||
					 #(xArray.all? {|x| x == xArray[0]} && type ==0) || 
					 #(yArray.all? {|y| y == yArray[0]} && type ==0)
			 
				  color = @materials.add "color"
				  color.texture = TEXTURES_DIR + texture_name
				  color.texture.size = 30
				  
				  color2 = @materials.add "color2"
				  color2.texture = TEXTURES_DIR + "floor.jpg"
				  color2.texture.size = 30
				  
				
				  entity.material = color

			  
			end
	   end 
		
	end
	
	def draw_garage()
			garage_base = draw_space @lenght, @lenght+4.0.m, 0, 6.0.m, @height-@wall_width, @height-@wall_width
			garage_base.back_material = @mat_out_wall
			garage_base.pushpull -@height+@wall_width
			
			g_roof = draw_space @lenght, @lenght+4.0.m, 0, 6.0.m, @height-@wall_width, @height-@wall_width
			g_roof.material = @mat_out_wall
			g_roof.pushpull(@wall_width)
			#color_surface(garage_base, "floor.jpg", 0, true)
			#color_surface(floor, "inside_wall.jpg", 2)
			#color_surface(garage_base, "outside_wall.jpg", 1, true)
			
			garage_room = draw_space @lenght, @lenght + 4.0.m - @wall_width, 0+@wall_width, 6.0.m-@wall_width, @height-@wall_width, @height-@wall_width
			garage_room.pushpull -@height + @wall_width + 0.01.m
			
			g = draw_space @lenght+@wall_width, @lenght + 4.0.m - @wall_width*2, 0, 0, 0.01.m, @height - @wall_width
			g.pushpull -@wall_width
			door = draw_space @lenght+@wall_width, @lenght + 4.0.m - @wall_width*2, @wall_width, @wall_width, 0.01.m, @height - @wall_width
			material = @materials.add("g_door")
			material.texture = TEXTURES_DIR + "g_door.jpg"
			material.texture.size = 30
			door.material = material 
			door.back_material = material
	end
	
	def draw_room(x1, x2, y1, y2, z1, z2)
		
		room = draw_space x1, x2, y1, y2, z1, z2
		room.material = @mat_int_wall
		room.pushpull (-@height+@floor_height)
		face = draw_space x1, x2, y1, y2, z1-@height+@floor_height, z2-@height+@floor_height
		face.material = @mat_floor_tile
		return room
	end
	
	def draw_large_window(x1, x2, y1, y2, z1, z2)
	
		window = draw_space(x1, x2, y1, y2, z1, z2)
		window.pushpull -@wall_width
		
	end
	
	def draw_window(x1, x2, y1, y2, z1, z2)

		window = draw_space(x1, x2, y1, y2, z1, z2)
		window.pushpull -@wall_width
		padding_mat = @materials.add("padding_mat")
		padding_mat.texture = TEXTURES_DIR + "padding.jpg"
		padding_mat.texture.size = 30
		
	if x1 == x2 && x1 == 0
      
      padding = draw_space(x1 + @wall_width - @window_padding,
                                  x2 + @wall_width - @window_padding,
                                  y1, y2,
                                  z1, z2)
      
      window = draw_space(x1 + @wall_width - @window_padding,
                                    x2 + @wall_width - @window_padding,
                                    y1 + @window_padding,
                                    y2 - @window_padding,
                                    z1 + @window_padding,
                                    z2 - @window_padding)
									
	  padding.back_material = padding_mat
	  padding.material = padding_mat	 
      padding.pushpull(-@window_padding/2)

      
    elsif x1 == x2 && x1 > 0
     
     padding = draw_space(x1 + @wall_width + @window_padding,
                                  x2 + @wall_width + @window_padding,
                                  y1, y2,
                                  z1, z2)
      
      window = draw_space(x1 + @wall_width + @window_padding,
                                    x2 + @wall_width + @window_padding,
                                    y1 + @window_padding,
                                    y2 - @window_padding,
                                    z1 + @window_padding,
                                    z2 - @window_padding)
									
	  padding.back_material = padding_mat
	  padding.material = padding_mat	
      padding.pushpull(@window_padding/2)

      
    elsif y1 == y2 && y1 == 0
      
	  padding = draw_space(x1, x2,
                                  y1 + @wall_width - @window_padding,
                                  y2 + @wall_width - @window_padding,
                                  z1, z2)
      
      window = draw_space(x1 + @window_padding,
                                    x2 - @window_padding,
                                    y1 + @wall_width - @window_padding,
                                    y2 + @wall_width - @window_padding,
                                    z1 + @window_padding,
                                    z2 - @window_padding)
	  
	  padding.back_material = padding_mat
	  padding.material = padding_mat	
      padding.pushpull(@window_padding/2)
      
    
    elsif y1 == y2 && y1 > 0
      
      padding = draw_space(x1, x2,
                                  y1 - @wall_width + @window_padding,
                                  y2 - @wall_width + @window_padding,
                                  z1, z2)
      
      window = draw_space(x1 + @window_padding,
                                    x2 - @window_padding,
                                    y1 - @wall_width + @window_padding,
                                    y2 - @wall_width + @window_padding,
                                    z1 + @window_padding,
                                    z2 - @window_padding)
									
	  padding.back_material = padding_mat
	  padding.material = padding_mat								
      padding.pushpull(-@window_padding/2)
	  
    end

	
    window_glass = @materials.add "Window Glass"
    window_glass.color = "#b3e6ff"
 
	window_glass.alpha = 0.5
    window.material = window_glass
    window.back_material = window_glass
	
	end

	
	def draw_door(x1, x2, y1, y2, z1, z2)
		
	 door = draw_space x1, x2, y1, y2, z1, z2
	 door.pushpull -@wall_width
	
	 if x1 == x2 
      
      p = draw_space(x1 + @door_padding,
                                  x2 + @door_padding,
                                  y1, y2,
                                  z1, z2)
								  
									
	  p.back_material = @padding_mat
	  p.material = @padding_mat	 
      p.pushpull(-@door_padding/2)
	  
	  if y1<y2
		  door_knob = draw_space(x1+@door_padding-0.04.m, x1+@door_padding-0.04.m, y1 + 0.10.m, y1 + 0.19.m, z2/2-0.02.m, z2/2 )
		  door_knob.pushpull 0.10.m
	  else
		  door_knob = draw_space(x1+@door_padding-0.04.m, x1+@door_padding-0.04.m, y2 + 0.10.m, y2 + 0.19.m, z2/2-0.02.m, z2/2 )
		  door_knob.pushpull 0.10.m
	  end
	  
    elsif y1 == y2 
      
	  p = draw_space(x1, x2,
                                  y1 + @door_padding,
                                  y2 + @door_padding,
                                  z1, z2)
     
	  p.back_material = @padding_mat
	  p.material = @padding_mat	
	  
	  p.pushpull(@door_padding/2) 
	  if x1<x2
		  door_knob = draw_space(x1+0.10.m, x1+0.19.m, y1 + @door_padding-0.10.m, y1 + @door_padding-0.10.m, z2/2-0.02.m, z2/2 )
		  door_knob.pushpull -0.10.m
	  else
		  door_knob = draw_space(x1+0.10.m, x1+0.19.m, y2 + @door_padding-0.10.m, y2 + @door_padding-0.10.m, z2/2-0.02.m, z2/2 )
		  door_knob.pushpull -0.10.m
	  end
	  
	end
	
	
  end

	
	 def draw_space(x0, x1, y0, y1, z0, z1)

		if x0 == x1
		  pt1 = [x0, y0, z0]
		  pt2 = [x0, y1, z0]
		  pt3 = [x0, y1, z1]
		  pt4 = [x0, y0, z1]
		elsif y0 == y1
		  pt1 = [x0, y0, z0]
		  pt2 = [x1, y0, z0]
		  pt3 = [x1, y0, z1]
		  pt4 = [x0, y0, z1]
		elsif z0 == z1
		  pt1 = [x0, y0, z0]
		  pt2 = [x1, y0, z0]
		  pt3 = [x1, y1, z0]
		  pt4 = [x0, y1, z0]
		else
		  pt1 = [x0, y0, z0]
		  pt2 = [x1, y0, z0]
		  pt3 = [x1, y1, z1]
		  pt4 = [x0, y1, z1]
		end
	
    @entities.add_face pt1, pt2, pt3, pt4
  end

end

h = House.new(12.0.m, 10.0.m, 3.0.m, true, true, 3)
h.draw