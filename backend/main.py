from fastapi import FastAPI, HTTPException, status, Query
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime

app = FastAPI(
    title="Chenla Smart Campus - Smart Room App API",
    description="Backend API សម្រាប់គ្រប់គ្រងបន្ទប់ បុគ្គលិក វត្តមាន និងចំណតម៉ូតូ",
    version="1.0.0"
)

# CORS Middleware សម្រាប់ Flutter Web & Mobile
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ====================================================
# MODELS
# ====================================================
class StaffModel(BaseModel):
    id: str
    name: str
    role: str
    shift: str
    building: str
    category: str
    image: Optional[str] = None

class RequestModel(BaseModel):
    room_number: str
    requested_by: str
    type: str
    description: str
    building: str

class CheckInRequest(BaseModel):
    username: Optional[str] = None
    note: Optional[str] = None

class ParkingTicketCreate(BaseModel):
    vehicle_type: str
    plate_number: str
    fee: int = 500
    shift: str = "វេនថ្ងៃ"
    staff_name: str = "សាន វិចិត្រ"

# ✅ Model សម្រាប់បន្ថែមបន្ទប់ថ្មី (Add Room)
class RoomModel(BaseModel):
    room_number: str
    building: str
    floor: int = 1
    type: str = "បន្ទប់ទូទៅ"
    status: str = "រួចរាល់"
    ac: bool = False
    light: bool = False
    lock: bool = True

# ====================================================
# DATABASE
# ====================================================
staff_db: List[dict] = [
    {"id": "CLU0001", "name": "សុខុម ថាងចេង", "role": "សាស្ត្រាចារ្យ (អគារ A)", "shift": "វេនព្រឹក (7:00 AM - 11:00 AM)", "building": "អគារ A", "category": "អគារ A", "image": "lib/src/sokhom.tc.jpg"},
    {"id": "CLU0002", "name": "គង់ វណ្ណៈ", "role": "ផ្នែកបច្ចេកទេស (អគារ B)", "shift": "វេនព្រឹក (6:00 AM - 2:00 PM)", "building": "អគារ B", "category": "អគារ B", "image": None},
    {"id": "CLU0003", "name": "ម៉េង ស្រីពៅ", "role": "ផ្នែកអនាម័យ (អគារ C - HR)", "shift": "វេនរសៀល (1:00 PM - 9:00 PM)", "building": "អគារ C", "category": "អគារ C", "image": None},
    {"id": "CLU0004", "name": "លី វិសាល", "role": "ផ្នែកសោរ (អគារ C)", "shift": "វេនយប់ (4:00 PM - 12:00 AM)", "building": "អគារ C", "category": "អគារ C", "image": None},
    {"id": "CLU0005", "name": "ពៅ សំបូរ", "role": "ចំណតម៉ូតូ", "shift": "វេនព្រឹក (7:30 AM - 5:30 PM)", "building": "ចំណតម៉ូតូ", "category": "ចំណតម៉ូតូ", "image": None},
    {"id": "CLU0006", "name": "សាន វិចិត្រ", "role": "ចំណតម៉ូតូ", "shift": "វេនព្រឹក (7:30 AM - 5:30 PM)", "building": "ចំណតម៉ូតូ", "category": "ចំណតម៉ូតូ", "image": None},
    {"id": "CLU0007", "name": "ជា ពិសិដ្ឋ", "role": "ចំណតម៉ូតូ", "shift": "វេនយប់ (5:30 PM - 9:30 PM)", "building": "ចំណតម៉ូតូ", "category": "ចំណតម៉ូតូ", "image": None}
]

rooms_db: List[dict] = [
    {"room_number": "A101", "building": "អគារ A", "floor": 1, "type": "បន្ទប់ទូទៅ", "status": "រួចរាល់", "ac": True, "light": True, "lock": True},
    {"room_number": "A102", "building": "អគារ A", "floor": 1, "type": "បន្ទប់ទូទៅ", "status": "កំពុងរៀបចំ", "ac": False, "light": True, "lock": False},
    {"room_number": "B201", "building": "អគារ B", "floor": 2, "type": "បន្ទប់ Lab", "status": "រួចរាល់", "ac": True, "light": True, "lock": True},
    {"room_number": "C301", "building": "អគារ C", "floor": 3, "type": "បន្ទប់ប្រជុំ", "status": "ផ្អាក/ខូច", "ac": False, "light": False, "lock": True},
]

requests_db: List[dict] = []
attendance_records: List[dict] = []
parking_tickets_db: List[dict] = [
    {"id": 1, "vehicle_type": "Scoopy", "plate_number": "1AK-8899", "fee": 500, "shift": "វេនថ្ងៃ", "staff_name": "សាន វិចិត្រ", "time": "08:15 AM"}
]

# ====================================================
# API ENDPOINTS
# ====================================================
@app.get("/")
def read_root():
    return {"status": "online", "message": "Chenla Smart Campus API is running!"}

# --- ROOMS APIS (ទាញយក និង បន្ថែមបន្ទប់ថ្មី) ---
@app.get("/api/rooms")
def get_rooms():
    return rooms_db

# ✅ API សម្រាប់ ADMIN បន្ថែមបន្ទប់ថ្មី
@app.post("/api/rooms", status_code=status.HTTP_201_CREATED)
def add_new_room(room: RoomModel):
    # ពិនិត្យលេខបន្ទប់ស្ទួន
    for r in rooms_db:
        if r["room_number"].lower() == room.room_number.lower():
            raise HTTPException(status_code=400, detail="លេខបន្ទប់នេះមានរួចហើយ")
    
    new_room = room.model_dump()
    rooms_db.append(new_room)
    return {"status": "success", "message": "បានបន្ថែមបន្ទប់ជោគជ័យ", "data": new_room}

# --- STAFF APIS ---
@app.get("/api/staff", response_model=List[StaffModel])
def get_all_staff():
    return staff_db

@app.post("/api/staff", response_model=StaffModel, status_code=status.HTTP_201_CREATED)
def create_staff(staff: StaffModel):
    for existing in staff_db:
        if existing["id"].lower() == staff.id.lower():
            raise HTTPException(status_code=400, detail="ID បុគ្គលិកនេះមានរួចហើយ")
    new_staff = staff.model_dump()
    staff_db.append(new_staff)
    return new_staff

# --- ATTENDANCE & PARKING & REQUESTS ---
@app.get("/api/attendance/today")
def get_today_duty(username: Optional[str] = Query(None)):
    return {
        "time": "05:00 AM",
        "title": "ត្រួតពិនិត្យ និងបើកបន្ទប់ទទួលបន្ទុក",
        "note": "កត់ត្រាវត្តមាន Check-in មុនចាប់ផ្ដើមការងារ"
    }

@app.post("/api/attendance/check-in")
def check_in(payload: Optional[CheckInRequest] = None):
    now_str = datetime.now().strftime("%I:%M %p")
    return {"status": "success", "message": f"បាន Check-in ជោគជ័យនៅម៉ោង {now_str}", "time": now_str}

@app.get("/api/parking/tickets")
def get_parking_tickets():
    return parking_tickets_db

@app.post("/api/parking/tickets", status_code=status.HTTP_201_CREATED)
def create_parking_ticket(ticket: ParkingTicketCreate):
    t_dict = ticket.model_dump()
    t_dict["id"] = len(parking_tickets_db) + 1
    t_dict["time"] = datetime.now().strftime("%I:%M %p")
    parking_tickets_db.insert(0, t_dict)
    return {"status": "success", "message": "បានកឹបសំបុត្រម៉ូតូ ៥០០៛ ជោគជ័យ", "data": t_dict}

@app.post("/api/requests", status_code=status.HTTP_201_CREATED)
def create_request(request: RequestModel):
    req_dict = request.model_dump()
    req_dict["id"] = f"REQ{len(requests_db) + 1:04d}"
    requests_db.append(req_dict)
    return {"status": "success", "message": "សំណើត្រូវបានបង្កើតដោយជោគជ័យ", "data": req_dict}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)