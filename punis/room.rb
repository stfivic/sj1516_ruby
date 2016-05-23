require_relative 'modern_house_floor'
require_relative 'material'
require_relative 'cardinal_point'


class Room
  attr_accessor :floor,:width,:height,:type,:position,:thickness,:room,:pts_1,:pts_2
  attr_accessor :door_material
 def initialize(f,o,t,x,y,w)
    @model = Sketchup.active_model
    @ent = @model.entities
    @floor=f
    @width=x
    @height=y
    
    @type=t
    @position=o
    @thickness=w
    @room=[]
    @pts_1=[]
    @pts_2=[]
    @door_material=Material::Wood1
    @doors=[]
    setRoom()
 end
  
 def setRoom()
    pts=[]
    if @position==CardinalPoint::West then
       pts[0]=[@floor.pts[0][0]+@width-@thickness,@floor.pts[0][1]+1,@floor.pts[0][2]]
       pts[1]=[@floor.pts[0][0]+@width,@floor.pts[0][1]+1,@floor.pts[0][2]]
       pts[2]=[@floor.pts[3][0]+@width,@floor.pts[3][1]-1,@floor.pts[3][2]]
       pts[3]=[@floor.pts[3][0]+(@width-@thickness),@floor.pts[3][1]-1,@floor.pts[3][2]]
       @pts_1=pts
       temp=@ent.add_face pts_1
       temp.pushpull (@floor.pushheight - 1)
       @room.push(temp)
    elsif @position==CardinalPoint::Est then
       pts[0]=[@floor.pts[1][0]-@width,@floor.pts[1][1]+1,@floor.pts[1][2]]
       pts[1]=[@floor.pts[1][0]-@width+@thickness,@floor.pts[1][1]+1,@floor.pts[1][2]]
       pts[2]=[@floor.pts[2][0]-@width+@thickness,@floor.pts[2][1]-1,@floor.pts[2][2]]
       pts[3]=[@floor.pts[2][0]-@width,@floor.pts[2][1]-1,@floor.pts[2][2]]
       @pts_1=pts
       temp=@ent.add_face pts
       temp.pushpull (@floor.pushheight - 1)
       @room.push(temp)
    elsif @position==CardinalPoint::South then
       pts[0]=[@floor.pts[0][0]+1,@floor.pts[0][1]+@width-@thickness,@floor.pts[1][2]]
       pts[1]=[@floor.pts[1][0]-1,@floor.pts[1][1]+@width-@thickness,@floor.pts[1][2]]
       pts[2]=[@floor.pts[1][0]-1,@floor.pts[1][1]+@width,@floor.pts[1][2]]
       pts[3]=[@floor.pts[0][0]+1,@floor.pts[0][1]+@width,@floor.pts[0][2]]
       @pts_1=pts
       temp=@ent.add_face pts
       temp.pushpull (@floor.pushheight - 1)
       @room.push(temp)
    elsif @position==CardinalPoint::North then
       pts[0]=[@floor.pts[3][0]+1,@floor.pts[3][1]-@width+@thickness,@floor.pts[3][2]]
       pts[1]=[@floor.pts[2][0]-1,@floor.pts[2][1]-@width+@thickness,@floor.pts[2][2]]
       pts[2]=[@floor.pts[2][0]-1,@floor.pts[2][1]-@width,@floor.pts[2][2]]
       pts[3]=[@floor.pts[3][0]+1,@floor.pts[3][1]-@width,@floor.pts[3][2]]
       @pts_1=pts
       temp=@ent.add_face pts
       temp.pushpull (@floor.pushheight - 1)
       @room.push(temp)
    elsif @position==CardinalPoint::NorthWest then
       pts[0]=[@floor.pts[3][0]+1,@floor.pts[3][1]-@height,@floor.pts[3][2]]
       pts[1]=[@floor.pts[3][0]+@width,@floor.pts[3][1]-@height,@floor.pts[3][2]]
       pts[2]=[@floor.pts[3][0]+@width,@floor.pts[3][1]-@height+@thickness,@floor.pts[3][2]]
       pts[3]=[@floor.pts[3][0]+1,@floor.pts[3][1]-@height+@thickness,@floor.pts[3][2]]
       @pts_1=pts
       temp=@ent.add_face pts
       temp.pushpull (@floor.pushheight - 1)
       @room.push(temp)
       pts=[]
       pts[0]=[@pts_1[1][0]-@thickness,@pts_1[1][1]+1.mm,@pts_1[2][2]]
       pts[1]=[@pts_1[1][0],@pts_1[1][1]+1.mm,@pts_1[2][2]]
       pts[2]=[@pts_1[1][0],@floor.pts[3][1]-1,@pts_1[2][2]]
       pts[3]=[@pts_1[1][0]-@thickness,@floor.pts[3][1]-1,@pts_1[2][2]]
       @pts_2=pts
       temp=@ent.add_face pts
       temp.pushpull (@floor.pushheight - 1)
       @room.push(temp)
    elsif @position==CardinalPoint::SouthEst then
       pts[0]=[@floor.pts[1][0]-@width,@floor.pts[1][1]+@height-@thickness,@floor.pts[1][2]]
       pts[1]=[@floor.pts[1][0]-1,@floor.pts[1][1]+@height-@thickness,@floor.pts[1][2]]
       pts[2]=[@floor.pts[1][0]-1,@floor.pts[1][1]+@height,@floor.pts[1][2]]
       pts[3]=[@floor.pts[1][0]-@width,@floor.pts[1][1]+@height,@floor.pts[1][2]]
       @pts_1=pts
       temp=@ent.add_face pts
   
       temp.pushpull (@floor.pushheight - 1)
       @room.push(temp)
       pts=[]
       pts[0]=[@pts_1[0][0],@floor.pts[0][0]+1,@pts_1[0][2]]
       pts[1]=[@pts_1[0][0]+@thickness,@floor.pts[0][0]+1,@pts_1[0][2]]
       pts[2]=[@pts_1[0][0],@pts_1[0][1],@pts_1[0][2]]
       pts[3]=[@pts_1[0][0]-@thickness,@pts_1[0][1],@pts_1[0][2]]
       @pts_2=pts
       temp=@ent.add_face pts
       temp.pushpull (@floor.pushheight - 1)
       @room.push(temp)    
    elsif @position==CardinalPoint::SouthWest then
       pts[0]=[@floor.pts[0][0]+1,@floor.pts[0][1]+@height-@thickness,@floor.pts[0][2]]
       pts[1]=[@floor.pts[0][0]+@width,@floor.pts[0][1]+@height-@thickness,@floor.pts[0][2]]
       pts[2]=[@floor.pts[0][0]+@width,@floor.pts[0][1]+@height,@floor.pts[0][2]]
       pts[3]=[@floor.pts[0][0]+1,@floor.pts[0][1]+@height,@floor.pts[0][2]]
       @pts_1=pts
       temp=@ent.add_face pts

       temp.pushpull (@floor.pushheight - 1)
       @room.push(temp)
       pts=[]
       pts[0]=[@pts_1[1][0]-@thickness,@floor.pts[0][0]+1,@pts_1[1][2]]
       pts[1]=[@pts_1[1][0],@floor.pts[0][0]+1,@pts_1[1][2]]
       pts[2]=[@pts_1[1][0],@pts_1[0][1]-1.mm,@pts_1[1][2]]
       pts[3]=[@pts_1[1][0]-@thickness,@pts_1[0][1]-1.mm,@pts_1[1][2]]
       @pts_2=pts
       temp=@ent.add_face pts
  
       temp.pushpull (@floor.pushheight - 1) 
       @room.push(temp)    
    elsif @position==CardinalPoint::NorthEst then
       pts[0]=[@floor.pts[2][0]-@width,@floor.pts[2][1]-@height,@floor.pts[2][2]]
       pts[1]=[@floor.pts[2][0]-1,@floor.pts[2][1]-@height,@floor.pts[2][2]]
       pts[2]=[@floor.pts[2][0]-1,@floor.pts[2][1]-@height+@thickness,@floor.pts[2][2]]
       pts[3]=[@floor.pts[2][0]-@width,@floor.pts[2][1]-@height+@thickness,@floor.pts[2][2]]
       @pts_1=pts
       temp=@ent.add_face pts

       temp.pushpull (@floor.pushheight - 1)
       @room.push(temp)
       pts=[]
       pts[0]=[@pts_1[3][0],@pts_1[3][1],@pts_1[3][2]]
       pts[1]=[@pts_1[3][0]+@thickness,@pts_1[3][1]-1,@pts_1[3][2]]
       pts[2]=[@pts_1[3][0]+@thickness,@floor.pts[2][1]-1,@pts_1[1][2]]
       pts[3]=[@pts_1[3][0],@floor.pts[2][1]-1,@pts_1[1][2]]
       @pts_2=pts
       temp=@ent.add_face pts

       temp.pushpull (@floor.pushheight - 1) 
       @room.push(temp)    
    end
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
 
def addDoor(distX,main_door,sizeX,sizeY)
    pts=[]
    start_pt=[]
    pos=0
    if main_door then
      start_pt=@pts_1[0]
      if @position==CardinalPoint::NorthEst || @position==CardinalPoint::NorthWest then
        pos=CardinalPoint::North
      elsif @position==CardinalPoint::SouthEst || @position==CardinalPoint::SouthWest then
        pos=CardinalPoint::South
      else
        pos=@position
   
      end

    else 
      start_pt=@pts_2[0]
      if @position==CardinalPoint::NorthEst || @position==CardinalPoint::SouthEst then
        pos=CardinalPoint::Est
      elsif @position==CardinalPoint::NorthWest || @position==CardinalPoint::SouthWest then
        pos=CardinalPoint::West
      else
        pos=-1
        return #nema drugi vrata jer ima samo jedan zid
      end
    end
    if pos==CardinalPoint::South || pos==CardinalPoint::North then
      pts[0]=[start_pt[0]+distX,start_pt[1],start_pt[2]]
      pts[1]=[pts[0][0]+sizeX,pts[0][1],pts[0][2]]
      pts[2]=[pts[0][0]+sizeX,pts[0][1],pts[0][2]+sizeY]
      pts[3]=[pts[0][0],pts[0][1],pts[0][2]+sizeY]
    elsif pos==CardinalPoint::Est || pos==CardinalPoint::West
      pts[0]=[start_pt[0],start_pt[1]+distX,start_pt[2]]
      pts[1]=[pts[0][0],pts[0][1]+sizeX,pts[0][2]]
      pts[2]=[pts[0][0],pts[0][1]+sizeX,pts[0][2]+sizeY]
      pts[3]=[pts[0][0],pts[0][1],pts[0][2]+sizeY]
    end 
    f=@ent.add_face pts
    f.material=Material::Wood1
    f.back_material=Material::Wood1
    @doors.push(f)
  end

end
