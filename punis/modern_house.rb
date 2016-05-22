class ModernHouse
  
  attr_accessor :floors, :roof, :roof_sup, :floorDelimiter,:floorSeparator,:materials
  TEXTURES_DIR = "C:/Users/Josip/AppData/Roaming/SketchUp/SketchUp 2016/SketchUp/Textures/"
  DEFAULT_TEXTURE_SIZE=50
  def initialize()
    #Sketchup.remove_observer
    @model = Sketchup.active_model
    @ent = @model.entities
    @floors=[]
    @floorDelimiter=[]
    @floorSeparator=nil
    @height=0
    @width=0
    @depth=0
    @roof=[]
    @materials = @model.materials
    loadMaterials()
  end

def materialDefined(name)
  for m in @materials
    if m.name==name
      return true
    end
  end
  return false
end

def loadMaterials()
  Material.constants.each do |c| 
    name=Material.const_get(c)
    if !materialDefined(name) then
       m=@materials.add(name)
       m.texture=TEXTURES_DIR+name+'.jpg'
       m.texture.size = DEFAULT_TEXTURE_SIZE
    end
  end
end

  def setHouse(x,y,z)
    @height=z
    @width=x
    @depth=y
    setFloor(1,x,y,0,z/2)
    setFloor(2,x,y,z/2,z/2)
    setFloorSeparator(10.cm)
  end
  
  def deleteHouse()
    @ent.clear!
  end
  
  def setFloor(n,x,y,z,h)
    
    temp =ModernHouseFloor.new n
    temp.setSize(x,y,z,h)
    if n>0 then
      @floors[n-1]=temp
    end
    
  end

  def setFloorDelimiter(n,ny,nz) #ne koristi,bolje s dekorom
      @floorDelimiter[n]=[] 
      fpts=@floors[n].getFloorDimension()
      for i in 0..fpts.size-1
        if i==fpts.size-1 then
          j=0
        else
          j=i+1
        end
        pts=[]
        pts[0]=[fpts[i][0],fpts[i][1],@floors[n].height - ny/2]
        pts[1]=[fpts[j][0],fpts[j][1],@floors[n].height - ny/2]
        pts[2]=[fpts[j][0],fpts[j][1],@floors[n].height + ny/2]
        pts[3]=[fpts[i][0],fpts[i][1],@floors[n].height + ny/2]
        
        tmp=@ent.add_face pts
        tmp.pushpull nz
        @floorDelimiter[n].push(tmp)
      end 
     @floors[0].updateFace(false) #mozda nije potreban
     @floors[1].updateFace(false) #mozda nije potreban
  end

  def setFloorSeparator(x)
    pts=[]
    for i in 0..@floors.size - 1
      pts[0]=[@floors[i].pts[0][0]+1,@floors[i].pts[0][1]+1,@floors[i].pts[0][2]+(@height/2 - x/2)]
      pts[1]=[@floors[i].pts[1][0]-1,@floors[i].pts[1][1]+1,@floors[i].pts[1][2]+(@height/2 - x/2)]
      pts[2]=[@floors[i].pts[2][0]-1,@floors[i].pts[2][1]-1,@floors[i].pts[2][2]+(@height/2 - x/2)]
      pts[3]=[@floors[i].pts[3][0]+1,@floors[i].pts[3][1]-1,@floors[i].pts[3][2]+(@height/2 - x/2)]
      @floorSeparator=@ent.add_face pts
      @floorSeparator.pushpull x
      adjustFloorHeight(x)
    end  
  end

def setSupplementFloorSeparator(x)
    pts=[]
    for i in 0..@floors.size - 2
      if @floors[i].supplement_orientation==@floors[i+1].supplement_orientation then
        pts[0]=[@floors[i].pts_sup[0][0]+1,@floors[i].pts_sup[0][1]+1,@floors[i].pts_sup[0][2]+(@height/2 - x/2)]
        pts[1]=[@floors[i].pts_sup[1][0]-1,@floors[i].pts_sup[1][1]+1,@floors[i].pts_sup[1][2]+(@height/2 - x/2)]
        pts[2]=[@floors[i].pts_sup[2][0]-1,@floors[i].pts_sup[2][1]-1,@floors[i].pts_sup[2][2]+(@height/2 - x/2)]
        pts[3]=[@floors[i].pts_sup[3][0]+1,@floors[i].pts_sup[3][1]-1,@floors[i].pts_sup[3][2]+(@height/2 - x/2)]
        @floorSeparator=@ent.add_face pts
        @floorSeparator.pushpull x
      end
    end 
end

  def adjustFloorHeight(x)
    for r in 0..@floors.size - 1 
      if r==0
        @floors[r].pushheight += x/2
      else
        @floors[r].pushheight -= x/2
        end
    end
  end
  
  
  
  def setRoof(x,y,z)
    spts=@floors.last.pts
    pts=[]
    pts[0]=[spts[0][0]-x,spts[0][1]-y,spts[0][2]+@floors.last.height]
    pts[1]=[spts[1][0]+x,spts[1][1]-y,spts[0][2]+@floors.last.height]
    pts[2]=[spts[2][0]+x,spts[2][1]+y,spts[0][2]+@floors.last.height]
    pts[3]=[spts[3][0]-x,spts[3][1]+y,spts[0][2]+@floors.last.height]
   
    if(@floors.last.supplement) then
      sptss=@floors.last.pts_sup
      pts_sup=[]
      if @floors.last.supplement_orientation == CardinalPoint::NorthEst or @floors.last.supplement_orientation == CardinalPoint::SouthEst then
        pts_sup[0]=[sptss[0][0],sptss[0][1]-y,sptss[0][2]+@floors.last.height]
        pts_sup[3]=[sptss[3][0],sptss[3][1]+y,sptss[0][2]+@floors.last.height]
      else
        pts_sup[0]=[sptss[0][0]-x,sptss[0][1]-y,sptss[0][2]+@floors.last.height]
        pts_sup[3]=[sptss[3][0]-x,sptss[3][1]+y,sptss[0][2]+@floors.last.height]
      end
      if @floors.last.supplement_orientation == CardinalPoint::NorthWest or @floors.last.supplement_orientation == CardinalPoint::SouthWest then
        pts_sup[1]=[sptss[1][0],sptss[1][1]-y,sptss[0][2]+@floors.last.height]
        pts_sup[2]=[sptss[2][0],sptss[2][1]+y,sptss[0][2]+@floors.last.height]
      else
        pts_sup[1]=[sptss[1][0]+x,sptss[1][1]-y,sptss[0][2]+@floors.last.height]
        pts_sup[2]=[sptss[2][0]+x,sptss[2][1]+y,sptss[0][2]+@floors.last.height]
      end
      @roof_sup=@ent.add_face pts_sup
      @roof_sup.pushpull z
      
    end 
    temp=@ent.add_face pts
    temp.pushpull z
    @roof.push(temp)
    detectRoof()
  end

  def detectRoof()
   for temp_ent in @model.entities
    if temp_ent.typename() =='Face' and temp_ent.valid? then
        edge_in=0
        for temp_edge in temp_ent.edges
            if (temp_edge.vertices[0].position[2]>@height && temp_edge.vertices[0].position[2]>@height ) then
                @roof.push(temp_ent)
                break
            end
      
        end
    
      end
    end 
  end

  def addRoofMaterial(new_material)
   for i in @roof
      if i.valid? then
        i.material=new_material
      end
    end
  end
  #sluzi samo za prikaz demo kuce
  def demoHouse(mh)
    
    mh.setHouse(10.m,20.m,8.m)
    mh.floors[0].setSupplement(10.m,10.m,CardinalPoint::SouthEst)
    mh.floors[1].setSupplement(10.m,10.m,CardinalPoint::SouthEst)
    mh.setSupplementFloorSeparator(10.cm)
    mh.setRoof(0.5.m,0.5.m,0.5.m)
    
    mh.floors[0].decorateSupplement(35.cm,6.cm,CardinalPoint::Est)
    mh.floors[0].decorateSupplement(35.cm,6.cm,CardinalPoint::North)
    mh.floors[0].decorateSupplement(35.cm,6.cm,CardinalPoint::South)
    mh.floors[1].decorateSupplement(35.cm,6.cm,CardinalPoint::Est)
    mh.floors[1].decorateSupplement(35.cm,6.cm,CardinalPoint::South)
    mh.floors[1].decorateSupplement(35.cm,6.cm,CardinalPoint::North)
    
    mh.floors[0].decorateFloor(35.cm,6.cm,CardinalPoint::West)
    mh.floors[1].decorateFloor(35.cm,6.cm,CardinalPoint::West)
    mh.floors[0].decorateFloor(35.cm,6.cm,CardinalPoint::Est)
    mh.floors[1].decorateFloor(35.cm,6.cm,CardinalPoint::Est)
    mh.floors[0].decorateFloor(35.cm,6.cm,CardinalPoint::North)
    mh.floors[1].decorateFloor(35.cm,6.cm,CardinalPoint::North)
    mh.floors[0].decorateFloor(35.cm,6.cm,CardinalPoint::South)
    mh.floors[1].decorateFloor(35.cm,6.cm,CardinalPoint::South)
    
    mh.floors[0].addMaterialSupplement(Material::Glass2)
    mh.floors[1].addMaterialSupplement(Material::Glass2)
    mh.floors[0].addMaterial(Material::Stone3)
    mh.floors[1].addMaterial(Material::Stone3)
    mh.addRoofMaterial(Material::Stone1)
    
    mh.floors[0].addWindow(2.m,120.cm,CardinalPoint::North,80.cm,140.cm)
    mh.floors[0].addWindow(7.m,120.cm,CardinalPoint::North,80.cm,140.cm)
    mh.floors[1].addWindow(2.m,120.cm,CardinalPoint::North,80.cm,140.cm)
    mh.floors[1].addWindow(7.m,120.cm,CardinalPoint::North,80.cm,140.cm)
    mh.floors[0].addWindow(2.m,120.cm,CardinalPoint::South,80.cm,140.cm)
    mh.floors[0].addWindow(7.m,120.cm,CardinalPoint::South,80.cm,140.cm)
    mh.floors[1].addWindow(2.m,120.cm,CardinalPoint::South,80.cm,140.cm)
    mh.floors[1].addWindow(7.m,120.cm,CardinalPoint::South,80.cm,140.cm)
    mh.floors[0].addWindow(2.m,120.cm,CardinalPoint::West,80.cm,140.cm)
    mh.floors[0].addWindow(5.m,120.cm,CardinalPoint::West,80.cm,140.cm)
    mh.floors[0].addWindow(14.m,120.cm,CardinalPoint::West,80.cm,140.cm)
    mh.floors[0].addWindow(17.m,120.cm,CardinalPoint::West,80.cm,140.cm)
    mh.floors[1].addWindow(2.m,120.cm,CardinalPoint::West,80.cm,140.cm)
    mh.floors[1].addWindow(5.m,120.cm,CardinalPoint::West,80.cm,140.cm)
    mh.floors[1].addWindow(14.m,120.cm,CardinalPoint::West,80.cm,140.cm)
    mh.floors[1].addWindow(17.m,120.cm,CardinalPoint::West,80.cm,140.cm)
    mh.floors[1].changeWindowMaterial(Material::Glass2)
    
    mh.floors[0].addDoor(10.m,CardinalPoint::West,120.cm,250.cm)
    mh.floors[0].addSuplementDoor(2.m,120.cm,250.cm)
    mh.floors[1].addSuplementDoor(2.m,120.cm,250.cm)
    
    s1_0=Room.new(mh.floors[0],CardinalPoint::North,RoomType::Livingroom,10.m,1.m,10.cm)
    s1_0.addDoor(4.m,true,120.cm,250.cm)
    
    s2_0=Room.new(mh.floors[0],CardinalPoint::SouthWest,RoomType::Unknown,4.m,8.m,10.cm)
    s2_0.addDoor(2.m,true,120.cm,250.cm)
    
    s3_0=Room.new(mh.floors[0],CardinalPoint::SouthEst,RoomType::Kitchen,4.m,8.m,10.cm)
    s3_0.addDoor(2.m,true,120.cm,250.cm)
    
    s1_1=Room.new(mh.floors[1],CardinalPoint::South,RoomType::Masterbedroom,10.m,1.m,10.cm)
    s1_1.addDoor(4.m,true,120.cm,250.cm)
    
    s2_1=Room.new(mh.floors[1],CardinalPoint::SouthEst,RoomType::Bathroom,3.m,3.m,10.cm)
    s2_1.addDoor(1.m,true,120.cm,250.cm)
    
    s3_1=Room.new(mh.floors[1],CardinalPoint::NorthEst,RoomType::Masterbedroom,4.m,8.m,10.cm)
    s3_1.addDoor(2.m,true,120.cm,250.cm)
    
    s4_1=Room.new(mh.floors[1],CardinalPoint::NorthWest,RoomType::Masterbedroom,4.m,8.m,10.cm)
    s4_1.addDoor(2.m,true,120.cm,250.cm)

  end
  
end