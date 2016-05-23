require_relative 'material'
require_relative 'cardinal_point'
require_relative 'room'
require_relative 'room_type'

class ModernHouseFloor
  #dodati original_pts, working_pts
  #dodati funkciju update working_pts
  attr_accessor :pts,:pts_sup, :base, :height,:supplement,:supplement_orientation,:sup_decor,:flor_decor
  attr_accessor :pushheight
  attr_accessor :pts_decor,:pts_decor_sup
  attr_accessor :windows,:doors
  attr_accessor :rooms
  attr_accessor :window_material,:door_material
  def initialize(n)
    @floor_id=n
    @model = Sketchup.active_model
    @ent = @model.entities
    @pts= []
    @pts_sup=[]
    @sup_decor=[]
    @floor_decor=[]
    @pts_decor=[]
    @pts_decor_sup=[]
    @base=[]
    @supplement=[]
    @windows=[]
    @doors=[]
    @rooms=[]
    @window_material=Material::Glass1
    @door_material=Material::Wood1
  end
    
  def updateDecorPoints(n,x,y,z)
    @pts[n]=[@pts[n][0]+x,@pts[n][1]+y,@pts[n][2]+z]
  end
  
  def updateSupplementDecorPoints(n,x,y,z)
    @pts_decor_sup[n]=[@pts_decor_sup[n][0]+x,@pts_decor_sup[n][1]+y,@pts_decor_sup[n][2]+z]
  end
  
  def setSize(x,y,z,h)
    if z== 0 then # neznam zašto ali tako radi, kontrolirati kasnije taj minus
      @pushheight=-h
    else
      @pushheight=h
    end
    @height=h
    @pts[0]=[(0.m).to_f,(0.m).to_f,z.to_f]
    @pts[1]=[x.to_f,(0.m).to_f,z.to_f]
    @pts[2]=[x.to_f,y.to_f,z.to_f]
    @pts[3]=[0.m,y.to_f,z.to_f]
    @pts_decor=@pts.clone
    @base[0]=@ent.add_face @pts
    @base[0].pushpull @pushheight
    @base=updateFaces(false)
  end
  
  def isVertexIn(v,points)
    t_pts=v.position
    if t_pts[0].nil?
      t_pts[0]=0
    end
    if t_pts[1].nil?
      t_pts[1]=0
    end
    if t_pts[2].nil?
      t_pts[2]=0
    end
    x_max=points[0][0]
    y_min=points[0][1]
    y_max=points[0][1]
    x_min=points[0][0]
    z_min=points[0][2]
    z_max=points[0][2]
    for p in points
 
      if p[0] > x_max then
        x_max=p[0]
      elsif p[0] <x_min then
        x_min=p[0]
      end
      if p[1] > y_max then
        y_max=p[1]
      elsif p[1] <= y_min then
        y_min=p[1]
      end
      if p[2] > z_max then
        z_max=p[2]
      elsif p[2] <= z_min then
        z_min=p[2]
      end
    end
    a=x_min<=t_pts[0]  && t_pts[0]<=x_max
    b=y_min<=t_pts[1] && t_pts[1]<=y_max
    c=z_min<=t_pts[2] && t_pts[2]<=z_max+@height
    d=a && b && c
    return d
  end
  
def updateFaces(isSup)
  temp_base=[]
  p=[]
  if isSup then
    p=@pts_sup
    temp_base=@supplement
  else
    p=@pts
    temp_base=@base
  end
  for temp_ent in @model.entities
    if temp_ent.typename() =='Face' and temp_ent.valid? then
        edge_in=0
        for temp_edge in temp_ent.edges

            if (isVertexIn(temp_edge.vertices[0],p) and isVertexIn(temp_edge.vertices[1],p)) then
                if edge_in > 1 then
                   temp_base.push(temp_ent)
                   break
                 else
                   edge_in=edge_in+1
                end
            end
        end
    
    end
  end
  if isSup then
    @supplement=temp_base
  else
    @base=temp_base
  end
  
  end
 
def setSupplement(x,y,orientation)

    start_point=[]
    @supplement_orientation=orientation
    case orientation  
      when CardinalPoint::SouthEst
         start_point=[@pts[1][0],@pts[0][1],@pts[0][2]]
      when CardinalPoint::SouthWest
         start_point=[@pts[0][0]-x,@pts[0][1],@pts[0][2]]
      when CardinalPoint::NorthEst
         start_point=[@pts[2][0],@pts[2][1]-y,@pts[2][2]]
     when CardinalPoint::NorthWest
         start_point=[@pts[3][0]-x,@pts[3][1]-y,@pts[3][2]]
     else
         start_point=[@pts[2][0],@pts[2][1]-y,@pts[2][2]]
    end
    
    @pts_sup[0]=[start_point[0],start_point[1],start_point[2]]
    @pts_sup[1]=[start_point[0]+x,start_point[1],start_point[2]]
    @pts_sup[2]=[start_point[0]+x,start_point[1]+y,start_point[2]]
    @pts_sup[3]=[start_point[0],start_point[1]+y,start_point[2]]
    
    @supplement[0]=@ent.add_face @pts_sup
    @pts_decor_sup=@pts_sup.clone
    @supplement[0].pushpull @pushheight 
    @supplement=updateFaces(true)
  end  
      
  def deleteSupplement()
    #to do
  end
  
  def deleteSupplementDecor(wall)
    #to do
  end  

  def colorFloor(color)
    
  end
  
  def addMaterial(new_material)
  for i in @base
    if i.valid? then
      i.material=new_material
    end
  end
  end
  
def addMaterialSupplement(new_material)
  for i in @supplement
    if i.valid? then
      i.material=new_material
    end
  end
end
  
  def drawRect(from,to,x,z)
    pts=[]
    pts[0]=from
    pts[1]=to
    pts[2]=[to[0],to[1],to[2]+x]
    pts[3]=[from[0],from[1],from[2]+x] 
    temp=@ent.add_face pts
    temp.pushpull z
    @sup_decor.push(temp)
  end
  
  def decorateFloor(x,z,wall)
    #x i y moraju biti array jer dajemo dimenzije za l gore, l dolje, d gore i d dolje
      if wall > CardinalPoint::West or wall < CardinalPoint::North
        return
      end
     
      pts=[]
      if wall==CardinalPoint::North then
         # drawRect(@pts[0],@pts[1],x,z)
          drawRect([@pts[1][0]-x,@pts[1][1],@pts[1][2]],[@pts[1][0],@pts[1][1],@pts[1][2]],@height,z)
          drawRect([@pts[0][0],@pts[0][1],@pts[0][2]],[@pts[0][0]+x,@pts[0][1],@pts[0][2]],@height,z)
          drawRect([@pts[0][0]+x,@pts[0][1],@pts[0][2]+@height],[@pts[1][0]-x,@pts[0][1],@pts[0][2]+@height],x,z)
       elsif wall==CardinalPoint::Est
        if @supplement_orientation == CardinalPoint::NorthEst
          #drawRect(@pts[1],@pts_sup[0],x,z)
          drawRect([@pts_sup[0][0],@pts_sup[0][1]-x,@pts_sup[0][2]],[@pts_sup[0][0],@pts_sup[0][1],@pts_sup[0][2]],@height,z)
          drawRect([@pts[1][0],@pts[1][1],@pts[1][2]],[@pts[1][0],@pts[1][1]+x,@pts[1][2]],@height,z)
          drawRect([@pts[1][0],@pts[1][1]+x,@pts[1][2]+@height],[@pts_sup[0][0],@pts_sup[0][1]-x,@pts_sup[0][2]+@height],x,z)
        elsif @supplement_orientation == CardinalPoint::SouthEst
          #drawRect(@pts_sup[3],@pts[2],x,z)
          drawRect([@pts[2][0],@pts[2][1]-x,@pts[2][2]],[@pts[2][0],@pts[2][1],@pts[2][2]],@height,z)
          drawRect([@pts_sup[3][0],@pts_sup[3][1]+x,@pts_sup[3][2]],[@pts_sup[3][0],@pts_sup[3][1],@pts_sup[3][2]],@height,z)
          drawRect([@pts_sup[3][0],@pts_sup[3][1]+x,@pts_sup[3][2]+@height],[@pts[2][0],@pts[2][1]-x,@pts[2][2]+@height],x,z)
        else
          #drawRect(@pts[1],@pts[2],x,z)
          drawRect([@pts[1][0],@pts[1][1],@pts[1][2]],[@pts[1][0],@pts[1][1]+x,@pts[1][2]],@height,z)
          drawRect([@pts[2][0],@pts[2][1]-x,@pts[2][2]],[@pts[2][0],@pts[2][1],@pts[2][2]],@height,z)
          drawRect([@pts[1][0],@pts[1][1]+x,@pts[1][2]+@height],[@pts[2][0],@pts[2][1]-x,@pts[2][2]+@height],x,z)      
        end
      elsif wall==CardinalPoint::South
         # drawRect(@pts[3],@pts[2],x,z)
          drawRect([@pts[3][0]+x,@pts[3][1],@pts[3][2]],[@pts[3][0],@pts[3][1],@pts[3][2]],@height,z)
          drawRect([@pts[2][0]-x,@pts[2][1],@pts[2][2]],[@pts[2][0],@pts[2][1],@pts[2][2]],@height,z)
          drawRect([@pts[3][0]+x,@pts[3][1],@pts[3][2]+@height],[@pts[2][0]-x,@pts[2][1],@pts[2][2]+@height],x,z)
      elsif wall==CardinalPoint::West
        if @supplement_orientation == CardinalPoint::NorthWest
         # drawRect(@pts_sup[1],@pts[0],x,z)
          drawRect([@pts[0][0],@pts[0][1]+x,@pts[0][2]],[@pts[0][0],@pts[0][1],@pts[0][2]],@height-x,z)
          drawRect([@pts_sup[1][0],@pts_sup[1][1]-x,@pts_sup[1][2]],[@pts_sup[1][0],@pts_sup[1][1],@pts_sup[1][2]],@height,z)
          drawRect([@pts_sup[1][0],@pts_sup[1][1]-x,@pts_sup[1][2]+@height],[@pts[0][0],@pts[0][1]+x,@pts[0][2]+@height],x,z)
        elsif @supplement_orientation == CardinalPoint::SouthWest
         # drawRect(@pts[3],@pts_sup[2],x,z)
          drawRect([@pts[3][0],@pts[3][1]-x,@pts[3][2]],[@pts[3][0],@pts[3][1],@pts[3][2]],@height,z)
          drawRect([@pts_sup[2][0],@pts_sup[2][1]+x,@pts_sup[2][2]],[@pts_sup[2][0],@pts_sup[2][1],@pts_sup[2][2]],@height,z)
          drawRect([@pts[3][0],@pts[3][1]-x,@pts[3][2]+@height],[@pts_sup[2][0],@pts_sup[2][1]+x,@pts_sup[2][2]+@height],x,z)
        else
         # drawRect(@pts[3],@pts[0],x,z)
          drawRect([@pts[3][0],@pts[3][1]-x,@pts[3][2]],[@pts[3][0],@pts[3][1],@pts[3][2]],@height,z)
          drawRect([@pts[0][0],@pts[0][1]+x,@pts[0][2]],[@pts[0][0],@pts[0][1],@pts[0][2]],@height,z)
          drawRect([@pts[3][0],@pts[3][1]-x,@pts[3][2]+@height],[@pts[0][0],@pts[0][1]+x,@pts[0][2]+@height],x,z)
        end

      end
    updateFaces(false)
  end
  
  def decorateSupplement(x,z,wall)
    #x i y moraju biti array jer dajemo dimenzije za l gore, l dolje, d gore i d dolje
      if wall > CardinalPoint::West or wall < CardinalPoint::North
        return
      end
    
      if wall==CardinalPoint::North then
         # drawRect(@pts_sup[0],@pts_sup[1],x,z)
          drawRect([@pts_sup[1][0]-x,@pts_sup[1][1],@pts_sup[1][2]],[@pts_sup[1][0],@pts_sup[1][1],@pts_sup[1][2]],@height,z)
          drawRect([@pts_sup[0][0],@pts_sup[0][1],@pts_sup[0][2]],[@pts_sup[0][0]+x,@pts_sup[0][1],@pts_sup[0][2]],@height,z)
          drawRect([@pts_sup[0][0]+x,@pts_sup[0][1],@pts_sup[0][2]+@height],[@pts_sup[1][0]-x,@pts_sup[0][1],@pts_sup[0][2]+@height],x,z)
      elsif wall==CardinalPoint::Est
         # drawRect(@pts_sup[1],@pts_sup[2],x,z)
          drawRect([@pts_sup[1][0],@pts_sup[1][1],@pts_sup[1][2]],[@pts_sup[1][0],@pts_sup[1][1]+x,@pts_sup[1][2]],@height,z)
          drawRect([@pts_sup[2][0],@pts_sup[2][1]-x,@pts_sup[2][2]],[@pts_sup[2][0],@pts_sup[2][1],@pts_sup[2][2]],@height,z)
          drawRect([@pts_sup[1][0],@pts_sup[1][1]+x,@pts_sup[1][2]+@height],[@pts_sup[2][0],@pts_sup[2][1]-x,@pts_sup[2][2]+@height],x,z)    

      elsif wall==CardinalPoint::South
         # drawRect(@pts_sup[3],@pts_sup[2],x,z)
          drawRect([@pts_sup[3][0]+x,@pts_sup[3][1],@pts_sup[3][2]],[@pts_sup[3][0],@pts_sup[3][1],@pts_sup[3][2]],@height,z)
          drawRect([@pts_sup[2][0]-x,@pts_sup[2][1],@pts_sup[2][2]],[@pts_sup[2][0],@pts_sup[2][1],@pts_sup[2][2]],@height,z)
          drawRect([@pts_sup[3][0]+x,@pts_sup[3][1],@pts_sup[3][2]+@height],[@pts_sup[2][0]-x,@pts_sup[2][1],@pts_sup[2][2]+@height],x,z)
      elsif wall==CardinalPoint::West
         # drawRect(@pts_sup[3],@pts_sup[0],x,z)
          drawRect([@pts_sup[3][0],@pts_sup[3][1]-x,@pts_sup[3][2]],[@pts_sup[3][0],@pts_sup[3][1],@pts_sup[3][2]],@height,z)
          drawRect([@pts_sup[0][0],@pts_sup[0][1]+x,@pts_sup[0][2]],[@pts_sup[0][0],@pts_sup[0][1],@pts_sup[0][2]],@height,z)
          drawRect([@pts_sup[3][0],@pts_sup[3][1]-x,@pts_sup[3][2]+@height],[@pts_sup[0][0],@pts_sup[0][1]+x,@pts_sup[0][2]+@height],x,z)
      end
    updateFaces(true)
  end
  
  def changeDoorMaterial(new_material)
    @door_material=new_material
    applyNewWindowMaterial()
  end
  
  def applyNewDoorMaterial()
    for d in @doors
      d.material=@door_material
    end
  end
  
  def changeWindowMaterial(new_material)
    @window_material=new_material
    applyNewWindowMaterial()
  end
  
  def applyNewWindowMaterial()
    for w in @windows
      w.material=@window_material
    end
  end
  
  
  def addWindow(distX,distY,wall,sizeX,sizeY)
    pts=[]
    start_pt=[]
    if wall==CardinalPoint::Est then
      start_pt=@pts[1]
      pts[0]=[start_pt[0],start_pt[1]+distX,start_pt[2]+distY]
      pts[1]=[pts[0][0],pts[0][1]+sizeX,pts[0][2]]
      pts[2]=[pts[0][0],pts[0][1]+sizeX,pts[0][2]+sizeY]
      pts[3]=[pts[0][0],pts[0][1],pts[0][2]+sizeY]
    elsif wall==CardinalPoint::West then
      start_pt=@pts[3]
      pts[0]=[start_pt[0],start_pt[1]-distX,start_pt[2]+distY]
      pts[1]=[pts[0][0],pts[0][1]-sizeX,pts[0][2]]
      pts[2]=[pts[0][0],pts[0][1]-sizeX,pts[0][2]+sizeY]
      pts[3]=[pts[0][0],pts[0][1],pts[0][2]+sizeY]
    elsif wall==CardinalPoint::South then
      start_pt=@pts[0]
      pts[0]=[start_pt[0]+distX,start_pt[1],start_pt[2]+distY]
      pts[1]=[pts[0][0]+sizeX,pts[0][1],pts[0][2]]
      pts[2]=[pts[0][0]+sizeX,pts[0][1],pts[0][2]+sizeY]
      pts[3]=[pts[0][0],pts[0][1],pts[0][2]+sizeY]
    elsif wall==CardinalPoint::North then
      start_pt=@pts[2]
      pts[0]=[start_pt[0]-distX,start_pt[1],start_pt[2]+distY]
      pts[1]=[pts[0][0]-sizeX,pts[0][1],pts[0][2]]
      pts[2]=[pts[0][0]-sizeX,pts[0][1],pts[0][2]+sizeY]
      pts[3]=[pts[0][0],pts[0][1],pts[0][2]+sizeY]
    else
      return 
    end

    f=@ent.add_face pts
    f.material=@window_material
    f.back_material=@window_material
    @windows.push(f)
  end
  
  def addDoor(distX,wall,sizeX,sizeY)
    pts=[]
    start_pt=[]
    if wall==CardinalPoint::Est then
      start_pt=@pts[1]
      pts[0]=[start_pt[0],start_pt[1]+distX,start_pt[2]]
      pts[1]=[pts[0][0],pts[0][1]+sizeX,pts[0][2]]
      pts[2]=[pts[0][0],pts[0][1]+sizeX,pts[0][2]+sizeY]
      pts[3]=[pts[0][0],pts[0][1],pts[0][2]+sizeY]
    elsif wall==CardinalPoint::West then
      start_pt=@pts[3]
      pts[0]=[start_pt[0],start_pt[1]-distX,start_pt[2]]
      pts[1]=[pts[0][0],pts[0][1]-sizeX,pts[0][2]]
      pts[2]=[pts[0][0],pts[0][1]-sizeX,pts[0][2]+sizeY]
      pts[3]=[pts[0][0],pts[0][1],pts[0][2]+sizeY]
    elsif wall==CardinalPoint::North then
      start_pt=@pts[0]
      pts[0]=[start_pt[0]+distX,start_pt[1],start_pt[2]]
      pts[1]=[pts[0][0]+sizeX,pts[0][1],pts[0][2]]
      pts[2]=[pts[0][0]+sizeX,pts[0][1],pts[0][2]+sizeY]
      pts[3]=[pts[0][0],pts[0][1],pts[0][2]+sizeY]
    elsif wall==CardinalPoint::South then
      start_pt=@pts[2]
      pts[0]=[start_pt[0]-distX,start_pt[1],start_pt[2]]
      pts[1]=[pts[0][0]-sizeX,pts[0][1],pts[0][2]]
      pts[2]=[pts[0][0]-sizeX,pts[0][1],pts[0][2]+sizeY]
      pts[3]=[pts[0][0],pts[0][1],pts[0][2]+sizeY]
    else
      return 
    end

    f=@ent.add_face pts
    f.material=Material::Wood1
    f.back_material=Material::Wood1
    @doors.push(f)
  end
  
  def getFloorDimension() #lose, poboljsati kasnije

    pts=[]
    if(@supplement)
      if @supplement_orientation== CardinalPoint::NorthEst
        pts[0]=@pts[0]
        pts[1]=@pts[1]
        pts[2]=@pts_sup[0]
        pts[3]=@pts_sup[1]
        pts[4]=@pts_sup[2]
        pts[5]=@pts[3]        
      elsif @supplement_orientation== CardinalPoint::NorthWest
        pts[0]=@pts[0]
        pts[1]=@pts[1]
        pts[2]=@pts[2]
        pts[3]=@pts_sup[3]
        pts[4]=@pts_sup[0]
        pts[5]=@pts_sup[1]
      elsif @supplement_orientation== CardinalPoint::SouthWest
        pts[0]=@pts_sup[0]
        pts[1]=@pts[1]
        pts[2]=@pts[2]
        pts[3]=@pts[3]
        pts[4]=@pts_sup[2]
        pts[5]=@pts_sup[3]        
      elsif @supplement_orientation== CardinalPoint::SouthEst 
        pts[0]=@pts[0]
        pts[1]=@pts_sup[1]
        pts[2]=@pts_sup[2]
        pts[3]=@pts_sup[3]
        pts[4]=@pts[2]
        pts[5]=@pts[3]
        end
    else
      pts=@pts
    end
    pts
 end
 
def addSuplementDoor(distX,sizeX,sizeY)
    pts=[]
    start_pt=[]
    if @supplement_orientation==CardinalPoint::NorthEst then
      start_pt=@pts_sup[0]
      pts[0]=[start_pt[0],start_pt[1]+distX,start_pt[2]]
      pts[1]=[pts[0][0],pts[0][1]+sizeX,pts[0][2]]
      pts[2]=[pts[0][0],pts[0][1]+sizeX,pts[0][2]+sizeY]
      pts[3]=[pts[0][0],pts[0][1],pts[0][2]+sizeY]
    elsif @supplement_orientation==CardinalPoint::NorthWest then
      start_pt=@pts_sup[1]
      pts[0]=[start_pt[0],start_pt[1]+distX,start_pt[2]]
      pts[1]=[pts[0][0],pts[0][1]+sizeX,pts[0][2]]
      pts[2]=[pts[0][0],pts[0][1]+sizeX,pts[0][2]+sizeY]
      pts[3]=[pts[0][0],pts[0][1],pts[0][2]+sizeY]
    elsif @supplement_orientation==CardinalPoint::SouthEst then
      start_pt=@pts[1]
      pts[0]=[start_pt[0],start_pt[1]+distX,start_pt[2]]
      pts[1]=[pts[0][0],pts[0][1]+sizeX,pts[0][2]]
      pts[2]=[pts[0][0],pts[0][1]+sizeX,pts[0][2]+sizeY]
      pts[3]=[pts[0][0],pts[0][1],pts[0][2]+sizeY]
    elsif @supplement_orientation==CardinalPoint::SouthWest then
      start_pt=@pts[0]
      pts[0]=[start_pt[0],start_pt[1]+distX,start_pt[2]]
      pts[1]=[pts[0][0],pts[0][1]+sizeX,pts[0][2]]
      pts[2]=[pts[0][0],pts[0][1]+sizeX,pts[0][2]+sizeY]
      pts[3]=[pts[0][0],pts[0][1],pts[0][2]+sizeY]
    else
      return 
    end

    f=@ent.add_face pts
    f.material=Material::Wood1
    @doors.push(f)
  end
  
  def getFloorDimension() #lose, poboljsati kasnije
    pts=[]
    if(@supplement)
      if @supplement_orientation== CardinalPoint::NorthEst
        pts[0]=@pts[0]
        pts[1]=@pts[1]
        pts[2]=@pts_sup[0]
        pts[3]=@pts_sup[1]
        pts[4]=@pts_sup[2]
        pts[5]=@pts[3]        
      elsif @supplement_orientation== CardinalPoint::NorthWest
        pts[0]=@pts[0]
        pts[1]=@pts[1]
        pts[2]=@pts[2]
        pts[3]=@pts_sup[3]
        pts[4]=@pts_sup[0]
        pts[5]=@pts_sup[1]
      elsif @supplement_orientation== CardinalPoint::SouthWest
        pts[0]=@pts_sup[0]
        pts[1]=@pts[1]
        pts[2]=@pts[2]
        pts[3]=@pts[3]
        pts[4]=@pts_sup[2]
        pts[5]=@pts_sup[3]        
      elsif @supplement_orientation== CardinalPoint::SouthEst 
        pts[0]=@pts[0]
        pts[1]=@pts_sup[1]
        pts[2]=@pts_sup[2]
        pts[3]=@pts_sup[3]
        pts[4]=@pts[2]
        pts[5]=@pts[3]
       
      end
    else
      pts=@pts
    end
    pts
 end


end
