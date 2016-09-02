require 'sketchup.rb'
SKETCHUP_CONSOLE.show

class MojaKuca
	def initialize ()
		@model = Sketchup.active_model
		@entities = @model.entities
		@materials = @model.materials
		@wall_mat = @materials.add("wall")
		@wall_mat.texture = TEXTURES_DIR + "wall.jpg"
		@wall_mat.texture.size = 30
		@bathroom_mat = @materials.add("bathroom")
		@bathroom_mat.texture = TEXTURES_DIR + "bathroom.jpg"
		@bathroom_mat.texture.size = 30
		@hallway_mat = @materials.add("hallway")
		@hallway_mat.texture = TEXTURES_DIR + "hallway.jpg"
		@hallway_mat.texture.size = 30
		@parquet_mat = @materials.add("parquet")
		@parquet_mat.texture = TEXTURES_DIR + "parquet.jpg"
		@parquet_mat.texture.size = 30
		@wallpaper_mat = @materials.add("wallpaper")
		@wallpaper_mat.texture = TEXTURES_DIR + "wallpaper.jpg"
		@wallpaper_mat.texture.size = 30
		@main_door_mat = @materials.add("modern_door")
		@main_door_mat.texture = TEXTURES_DIR + "modern_door.jpg"
		@main_door_mat.texture.size = 30
		@inner_door_mat = @materials.add("inner_door")
		@inner_door_mat.texture = TEXTURES_DIR + "inner_door.jpg"
		@inner_door_mat.texture.size = 30
		@roof_mat = @materials.add("roof")
		@roof_mat.texture = TEXTURES_DIR + "roof.jpg"
		@roof_mat.texture.size = 30
		@padding_mat = @materials.add("padding")
		@padding_mat.texture = TEXTURES_DIR + "padding.jpg"
		@padding_mat.texture.size = 30
		@window_glass = @materials.add "Window Glass"
		@window_glass.color = "#b3e6ff"
		@window_glass.alpha = 0.5
		@meter = 1.0.m
	end
	def sheet(x1,x2,y1,y2,z1,z2)
		if x1 == x2
		point1 = [x1,y1,z1]
		point2 = [x1,y1,z2]
		point3 = [x1,y2,z2]
		point4 = [x1,y2,z1]
		elsif y1 == y2
		point1 = [x1,y1,z1]
		point2 = [x2,y1,z1]
		point3 = [x2,y1,z2]
		point4 = [x1,y1,z2]
		elsif z1 == z2
		point1 = [x1,y1,z1]
		point2 = [x1,y2,z1]
		point3 = [x2,y2,z1]
		point4 = [x2,y1,z1]
		else
		point1 = [x1,y1,z1]
		point2 = [x2,y1,z1]
		point3 = [x2,y2,z2]
		point4 = [x1,y2,z2]
		end
		@entities.add_face point1, point2, point3, point4
	end
	
	def roof_side_y_axis (x1, x2, y1, y2, y3, z1, z2)
		point1 = [x1, y1, z1]
		point2 = [x1, y2, z1]
		point3 = [x2, y3, z2]
		@entities.add_face point1, point2, point3
	end
	
	def roof_side_x_axis (x1, x2, x3, y1, y2, z1, z2)
		point1 = [x1, y1, z1]
		point2 = [x2, y1, z1]
		point3 = [x3, y2, z2]
		@entities.add_face point1, point2, point3
	end
	
	def roof_sheet_x_axis (x1, x2, x3, x4, y1 , y2, z1, z2)
		point1 = [x1, y1, z1]
		point2 = [x2, y1, z1]
		point3 = [x4, y2, z2]
		point4 = [x3, y2, z2]
		@entities.add_face point1, point2, point3, point4
	end
	
	def roof_sheet_y_axis (x1, x2, y1, y2, y3, z1, z2)
		point1 = [x1, y1, z1]
		point2 = [x1, y2, z1]
		point3 = [x1, y3, z2]
		point4 = [x2, y1, z2]
		@entities.add_face point1, point2, point3, point4
	end
	
	def foundation()
		livingRoom = sheet 0, @meter*5, 0, @meter*7, 0, 0
		livingRoom.back_material = @wall_mat
		livingRoom.pushpull -@meter*2.5
		livingRoomFloor = sheet @meter/5, @meter*5-@meter/5, @meter/5, @meter*7-@meter/5, @meter/10, @meter/10
		livingRoomFloor.material = @wallpaper_mat
		livingRoomInner = livingRoomFloor.pushpull (-@meter*2.5+@meter/10+@meter/5)
		livingRoomFloor.back_material = @parquet_mat
		add_window 0, 0, @meter, @meter*3, @meter*0.7, @meter*1.5
		add_window 0, 0, @meter*4, @meter*6, @meter*0.7, @meter*1.5
		add_window @meter*1.2, @meter*4, 0, 0, @meter*0.7, @meter*1.5
		
		bathroom = sheet 0, @meter*5, @meter*7, @meter*11, 0, 0
		bathroom.back_material = @wall_mat
		bathroom.pushpull -@meter*2.5
		bathroomFloor = sheet @meter/5, @meter*5-@meter/5, @meter*7+@meter/5, @meter*11-@meter/5, @meter/10, @meter/10
		bathroomFloor.material = @bathroom_mat
		bathroomInner = bathroomFloor.pushpull (-@meter*2.5+@meter/10+@meter/5)
		bathroomFloor.back_material = @bathroom_mat
		add_window @meter*1.2, @meter*4, @meter*11, @meter*11, @meter*0.7, @meter*1.5
		
		hallway = sheet @meter*5, @meter*8, @meter*4, @meter*11, 0, 0
		hallway.back_material = @wall_mat
		hallway.pushpull -@meter*2.5
		hallwayFloor = sheet @meter*5.0001, @meter*8-@meter*0.0001, @meter*4+@meter/5, @meter*11-@meter/5, @meter/10, @meter/10
		hallwayFloor.material = @wallpaper_mat
		hallwayInner = hallwayFloor.pushpull (-@meter*2.5+@meter/10+@meter/5)
		hallwayFloor.back_material = @hallway_mat
		add_window @meter*6.2, @meter*7, @meter*11, @meter*11, @meter*0.7, @meter*1.5
		add_door @meter*6, @meter*7, @meter*4, @meter*4, @meter/10, @meter*1.6
		add_door @meter*5.0001, @meter*5.0001, @meter*5, @meter*6, @meter/10, @meter*1.6
		add_door @meter*5.0001, @meter*5.0001, @meter*8.5, @meter*9.5, @meter/10, @meter*1.6
		add_door @meter*8-@meter*0.0001, @meter*8-@meter*0.0001, @meter*8.5, @meter*9.5, @meter/10, @meter*1.6
		
		bedroom = sheet @meter*8.0005, @meter*15, @meter*4, @meter*11, 0, 0
		bedroom.back_material = @wall_mat
		bedroom.pushpull -@meter*2.5
		bedroomFloor = sheet @meter*8+@meter/5, @meter*15-@meter/5, @meter*4+@meter/5, @meter*11-@meter/5, @meter/10, @meter/10
		bedroomFloor.material = @wallpaper_mat
		bedroomInner = bedroomFloor.pushpull (-@meter*2.5+@meter/10+@meter/5)
		bedroomFloor.back_material = @parquet_mat
		add_window @meter*10.3, @meter*12.8, @meter*11, @meter*11, @meter*0.7, @meter*1.5
		add_window @meter*14.8, @meter*14.8, @meter*6.4, @meter*8.4, @meter*0.7, @meter*1.5
	end
	
	def add_window(x1,x2,y1,y2,z1,z2)
		window = sheet(x1, x2, y1, y2, z1, z2)
		window.pushpull -@meter/5
		if x1 == x2 && x1 == 0
			frame = sheet(x1 + @meter/5 - @meter/20, x2 + @meter/5 - @meter/20, y1, y2, z1, z2)
			window = sheet(x1 + @meter/5 - @meter/20, x2 + @meter/5 - @meter/20, y1 + @meter/20, y2 - @meter/20, z1 + @meter/20, z2 - @meter/20)
			frame.back_material = @padding_mat
			frame.material = @padding_mat
			frame.pushpull -@meter/40
		elsif x1 == x2 && x1 > 0
			frame = sheet(x1 + @meter/5 + @meter/20, x2 + @meter/5 + @meter/20, y1, y2, z1, z2)
			window = sheet(x1 + @meter/5 + @meter/20, x2 + @meter/5 + @meter/20, y1 + @meter/20, y2 - @meter/20, z1 + @meter/20, z2 - @meter/20)
			frame.back_material = @padding_mat
			frame.material = @padding_mat
			frame.pushpull +@meter/40
		elsif y1 == y2 && y1 == 0
			frame = sheet(x1, x2, y1 + @meter/5 - @meter/20, y2 + @meter/5 - @meter/20, z1, z2)
			window = sheet(x1 + @meter/20, x2 - @meter/20, y1 + @meter/5 - @meter/20, y2 + @meter/5 - @meter/20, z1 + @meter/20, z2 - @meter/20)
			frame.back_material = @padding_mat
			frame.material = @padding_mat
			frame.pushpull @meter/40
		elsif y1 == y2 && y1 > 0
			frame = sheet(x1, x2, y1 - @meter/5 + @meter/20, y2 - @meter/5 + @meter/20, z1, z2)
			window = sheet(x1 + @meter/20, x2 - @meter/20, y1 - @meter/5 + @meter/20, y2 - @meter/5 + @meter/20, z1 + @meter/20, z2 - @meter/20)
			frame.back_material = @padding_mat
			frame.material = @padding_mat
			frame.pushpull -@meter/40
		end
		window.material = @window_glass
		window.back_material = @window_glass
	end
	
	def add_door(x1, x2, y1, y2, z1, z2)
		doorSheet = sheet(x1, x2, y1, y2, z1, z2)
		if x1 == x2
			doorSheet.pushpull +@meter/5
			doorFrame = sheet(x1 + @meter/20 - @meter*0.0001, x2 + @meter/20 - @meter*0.0001, y1, y2, z1, z2)
			doorFrame.back_material = @inner_door_mat
			doorFrame.material = @inner_door_mat
			doorFrame.pushpull -@meter/40
		elsif y1 == y2
			doorSheet.pushpull -@meter/5
			doorFrame = sheet(x1, x2, y1 + @meter/20, y2 + @meter/20, z1, z2)
			doorFrame.back_material = @main_door_mat
			doorFrame.material = @main_door_mat
			doorFrame.pushpull @meter/40
		end
	end
	
	def roof()
		roofSideEast = roof_side_y_axis @meter*15.1, @meter*13.1, @meter*4-@meter/5, @meter*11+@meter/5, @meter*7.5, @meter*2.5+@meter/10, @meter/10+@meter*2.5+@meter*2
		roofSideEast.pushpull -@meter/5
		roofSideEast.back_material = @roof_mat
		roofSideEast.material = @roof_mat
		roofSheetFront = roof_sheet_x_axis @meter*5, @meter*15, @meter*4, @meter*13.1, @meter*3.8, @meter*7.5, @meter*2.5+@meter*0.15, @meter/10+@meter*2.5+@meter*2
		roofSheetFront.pushpull -@meter/5
		roofSheetFront.material = @roof_mat
	end
	
	def draw()
		foundation
		roof
	end
end

mojaKuca = MojaKuca.new
mojaKuca.draw