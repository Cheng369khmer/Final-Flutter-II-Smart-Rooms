from fastapi import FastAPI, HTTPException, status, Query
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime

app = FastAPI(
    title="Chenla Smart Campus - Smart Room App API",
    description="Backend API ពេញលេញសម្រាប់គ្រប់គ្រងបន្ទប់ បុគ្គលិក វត្តមាន សំណើសម្ភារៈ និងចំណតម៉ូតូ",
    version="1.0.0"
)

# =========================================================================
# ១. CORS CONFIGURATION (សម្រាប់ FLUTTER WEB & MOBILE)
# =========================================================================
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# =========================================================================
# ២. PYDANTIC MODELS (ទម្រង់ទិន្នន័យ)
# =========================================================================

# Model សម្រាប់បន្ទប់ (Room)
class RoomModel(BaseModel):
    room_number: str
    building: str
    floor: int = 1
    type: str = "បន្ទប់ទូទៅ"
    status: str = "រួចរាល់"
    ac: bool = False
    light: bool = False
    lock: bool = True

# Model សម្រាប់បុគ្គលិក (Staff)
class StaffModel(BaseModel):
    id: str
    name: str
    role: str
    shift: str
    building: str
    category: str
    image: Optional[str] = None

# Model សម្រាប់សំណើសម្ភារៈ & ជួសជុល (Requests)
class RequestModel(BaseModel):
    room_number: str
    requested_by: str
    type: str
    description: str
    building: str

# Model សម្រាប់កត់ត្រាវត្តមាន (Check-in)
class CheckInRequest(BaseModel):
    username: Optional[str] = None
    note: Optional[str] = None

# =========================================================================
# ៣. IN-MEMORY DATABASE (ទិន្នន័យ DYNAMIC)
# =========================================================================

# ១. បញ្ជីបន្ទប់ឆ្លាតវៃ (Rooms)
rooms_db: List[dict] = [
    {"room_number": "A101", "building": "អគារ A", "floor": 1, "type": "បន្ទប់ទូទៅ", "status": "រួចរាល់", "ac": True, "light": True, "lock": True},
    {"room_number": "A102", "building": "អគារ A", "floor": 1, "type": "បន្ទប់ទូទៅ", "status": "កំពុងរៀបចំ", "ac": False, "light": True, "lock": False},
    {"room_number": "B201", "building": "អគារ B", "floor": 2, "type": "បន្ទប់ Lab", "status": "កំពុងជួសជុល", "ac": False, "light": False, "lock": True},
    {"room_number": "C301", "building": "អគារ C", "floor": 3, "type": "បន្ទប់ប្រជុំ", "status": "ផ្អាក/ប្រើមិនបាន", "ac": False, "light": False, "lock": True},
    {"room_number": "C302", "building": "អគារ C", "floor": 3, "type": "បន្ទប់ទូទៅ", "status": "រួចរាល់", "ac": True, "light": True, "lock": True},
]

# ២. បញ្ជីបុគ្គលិក (Staff)
staff_db: List[dict] = [
    {"id": "CLU0001", "name": "សុខុម ថាងចេង", "role": "សាស្ត្រាចារ្យ (អគារ A)", "shift": "វេនព្រឹក (7:00 AM - 11:00 AM)", "building": "អគារ A", "category": "អគារ A", "image": "lib/src/sokhom.tc.jpg"},
    {"id": "CLU0002", "name": "គង់ វណ្ណៈ", "role": "ផ្នែកបច្ចេកទេស (អគារ B)", "shift": "វេនព្រឹក (6:00 AM - 2:00 PM)", "building": "អគារ B", "category": "អគារ B", "image": None},
    {"id": "CLU0003", "name": "ម៉េង ស្រីពៅ", "role": "ផ្នែកអនាម័យ (អគារ C - HR)", "shift": "វេនរសៀល (1:00 PM - 9:00 PM)", "building": "អគារ C", "category": "អគារ C", "image": None},
    {"id": "CLU0004", "name": "លី វិសាល", "role": "ផ្នែកសោរ (អគារ C)", "shift": "វេនយប់ (4:00 PM - 12:00 AM)", "building": "អគារ C", "category": "អគារ C", "image": None},
    {"id": "CLU0005", "name": "ពៅ សំបូរ", "role": "ចំណតម៉ូតូ", "shift": "វេនព្រឹក (7:30 AM - 5:30 PM)", "building": "ចំណតម៉ូតូ", "category": "ចំណតម៉ូតូ", "image": None},
    {"id": "CLU0006", "name": "សាន វិចិត្រ", "role": "ចំណតម៉ូតូ", "shift": "វេនព្រឹក (7:30 AM - 5:30 PM)", "building": "ចំណតម៉ូតូ", "category": "ចំណតម៉ូតូ", "image": None},
    {"id": "CLU0007", "name": "ជា ពិសិដ្ឋ", "role": "ចំណតម៉ូតូ", "shift": "វេនយប់ (5:30 PM - 9:30 PM)", "building": "ចំណតម៉ូតូ", "category": "ចំណតម៉ូតូ", "image": None}
]

# ៣. បញ្ជីសំណើសម្ភារៈ & ជួសជុល (Requests)
requests_db: List[dict] = []

# ៤. បញ្ជីវត្តមាន (Timesheet)
attendance_records: List[dict] = [
    {"name": "សុខុម ថាងចេង", "time": "07:05 AM", "status": "CHECK-IN", "role": "សាស្ត្រាចារ្យ"},
    {"name": "គង់ វណ្ណៈ", "time": "06:00 AM", "status": "CHECK-IN", "role": "ផ្នែកបច្ចេកទេស"},
]

# ៥. បញ្ជីសំបុត្រម៉ូតូ (Parking Tickets)
parking_tickets_db: List[dict] = [
    {"id": 1, "vehicle_type": "Scoopy", "plate_number": "1AK-8899", "fee": 500, "shift": "វេនថ្ងៃ", "staff_name": "សាន វិចិត្រ", "time": "08:15 AM"},
    {"id": 2, "vehicle_type": "Dream", "plate_number": "1BC-3456", "fee": 500, "shift": "វេនថ្ងៃ", "staff_name": "សាន វិចិត្រ", "time": "08:40 AM"}
]

# =========================================================================
# ៤. API ENDPOINTS
# =========================================================================

@app.get("/")
def read_root():
    return {
        "status": "online",
        "message": "Chenla Smart Campus API is running!",
        "docs_url": "http://localhost:8000/docs",
        "timestamp": datetime.now().isoformat()
    }

# -------------------------------------------------------------------------
# A. ROOMS APIS (CRUD សម្រាប់បន្ទប់)
# -------------------------------------------------------------------------

@app.get("/api/rooms")
def get_all_rooms():
    return rooms_db

@app.post("/api/rooms", status_code=status.HTTP_201_CREATED)
def add_new_room(room: RoomModel):
    for r in rooms_db:
        if r["room_number"].lower() == room.room_number.lower():
            raise HTTPException(status_code=400, detail="លេខបន្ទប់នេះមានរួចហើយ")
    new_room = room.model_dump()
    rooms_db.append(new_room)
    return {"status": "success", "message": "បានបន្ថែមបន្ទប់ជោគជ័យ", "data": new_room}

@app.delete("/api/rooms/{room_number}")
def delete_room(room_number: str):
    for index, r in enumerate(rooms_db):
        if r["room_number"].lower() == room_number.lower():
            deleted = rooms_db.pop(index)
            return {
                "status": "success",
                "message": f"បានលុបបន្ទប់ {deleted['room_number']} ដោយជោគជ័យ"
            }
    raise HTTPException(status_code=404, detail="រកមិនឃើញបន្ទប់នេះទេ")

@app.put("/api/rooms/{room_number}")
def update_room(room_number: str, updated_room: RoomModel):
    for index, r in enumerate(rooms_db):
        if r["room_number"].lower() == room_number.lower():
            rooms_db[index] = updated_room.model_dump()
            return {"status": "success", "message": "បានកែប្រែទិន្នន័យបន្ទប់ជោគជ័យ", "data": rooms_db[index]}
    raise HTTPException(status_code=404, detail="រកមិនឃើញបន្ទប់ដើម្បីកែប្រែទេ")

# -------------------------------------------------------------------------
# B. STAFF APIS (CRUD សម្រាប់បុគ្គលិក)
# -------------------------------------------------------------------------

@app.get("/api/staff", response_model=List[StaffModel])
def get_all_staff():
    return staff_db

@app.get("/api/staff/{staff_id}", response_model=StaffModel)
def get_staff_by_id(staff_id: str):
    for staff in staff_db:
        if staff["id"].lower() == staff_id.lower():
            return staff
    raise HTTPException(status_code=404, detail="រកមិនឃើញបុគ្គលិកនេះទេ")

@app.post("/api/staff", response_model=StaffModel, status_code=status.HTTP_201_CREATED)
def create_staff(staff: StaffModel):
    for existing in staff_db:
        if existing["id"].lower() == staff.id.lower():
            raise HTTPException(status_code=400, detail="ID បុគ្គលិកនេះមានរួចហើយ")
    new_staff = staff.model_dump()
    staff_db.append(new_staff)
    return new_staff

@app.put("/api/staff/{staff_id}", response_model=StaffModel)
def update_staff(staff_id: str, updated_data: StaffModel):
    for index, staff in enumerate(staff_db):
        if staff["id"].lower() == staff_id.lower():
            staff_db[index] = updated_data.model_dump()
            return staff_db[index]
    raise HTTPException(status_code=404, detail="រកមិនឃើញបុគ្គលិកដើម្បីកែប្រែទេ")

@app.delete("/api/staff/{staff_id}")
def delete_staff(staff_id: str):
    for index, staff in enumerate(staff_db):
        if staff["id"].lower() == staff_id.lower():
            deleted = staff_db.pop(index)
            return {"message": f"បានលុប {deleted['name']} ដោយជោគជ័យ"}
    raise HTTPException(status_code=404, detail="រកមិនឃើញបុគ្គលិកដើម្បីលុបទេ")

# -------------------------------------------------------------------------
# C. ATTENDANCE APIS (កត់ត្រាវត្តមាន)
# -------------------------------------------------------------------------

@app.get("/api/attendance/today")
def get_today_duty(username: Optional[str] = Query(None)):
    return {
        "time": "05:00 AM",
        "title": "ត្រួតពិនិត្យ និងបើកបន្ទប់ទទួលបន្ទុក",
        "note": "កត់ត្រាវត្តមាន Check-in មុនចាប់ផ្ដើមការងារ",
        "assigned_user": username or "បុគ្គលិក"
    }

@app.post("/api/attendance/check-in")
def check_in(payload: Optional[CheckInRequest] = None):
    now_str = datetime.now().strftime("%I:%M %p")
    record = {
        "name": payload.username if payload and payload.username else "អ្នកប្រើប្រាស់",
        "time": now_str,
        "status": "CHECK-IN",
        "role": "បុគ្គលិក"
    }
    attendance_records.insert(0, record)
    return {
        "status": "success",
        "message": f"បានកត់ត្រាវត្តមាន Check-in ជោគជ័យនៅម៉ោង {now_str}",
        "time": now_str,
        "data": record
    }

@app.post("/api/attendance/check-out")
def check_out(payload: Optional[CheckInRequest] = None):
    now_str = datetime.now().strftime("%I:%M %p")
    return {
        "status": "success",
        "message": f"បាន Check-out ជោគជ័យនៅម៉ោង {now_str}",
        "time": now_str
    }

@app.get("/api/attendance/timesheet")
def get_timesheet():
    return attendance_records

# -------------------------------------------------------------------------
# D. PARKING APIS (✅ កែសម្រួល API ចំណតម៉ូតូ ៥០០៛ ឱ្យទទួលគ្រប់ទម្រង់ទិន្នន័យ)
# -------------------------------------------------------------------------

@app.get("/api/parking/tickets")
def get_parking_tickets():
    return parking_tickets_db

@app.post("/api/parking/tickets", status_code=status.HTTP_201_CREATED)
def create_parking_ticket(ticket: dict):
    # ✅ ទទួលយកទិន្នន័យជា Dictionary ដើម្បីការពារការខុសឈ្មោះ Field រវាង camelCase និង snake_case
    v_type = ticket.get("vehicle_type") or ticket.get("vehicleType") or "Scoopy"
    p_num = ticket.get("plate_number") or ticket.get("plateNumber") or "មិនបញ្ជាក់"
    fee_val = ticket.get("fee", 500)
    shift_val = ticket.get("shift", "វេនថ្ងៃ")
    s_name = ticket.get("staff_name") or ticket.get("staffName") or "សាន វិចិត្រ"

    new_ticket = {
        "id": len(parking_tickets_db) + 1,
        "vehicle_type": v_type,
        "plate_number": p_num,
        "fee": fee_val,
        "shift": shift_val,
        "staff_name": s_name,
        "time": datetime.now().strftime("%I:%M %p")
    }
    parking_tickets_db.insert(0, new_ticket)
    return {
        "status": "success",
        "message": "បានកឹបសំបុត្រម៉ូតូ ៥០០៛ ជោគជ័យ",
        "data": new_ticket
    }

# -------------------------------------------------------------------------
# E. REQUESTS APIS (សំណើសម្ភារៈ & ជួសជុល)
# -------------------------------------------------------------------------

@app.post("/api/requests", status_code=status.HTTP_201_CREATED)
def create_request(request: RequestModel):
    req_dict = request.model_dump()
    req_dict["id"] = f"REQ{len(requests_db) + 1:04d}"
    req_dict["created_at"] = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    requests_db.append(req_dict)
    return {
        "status": "success",
        "message": "សំណើត្រូវបានបង្កើតដោយជោគជ័យ",
        "data": req_dict
    }

@app.get("/api/requests")
def get_all_requests():
    return requests_db

# =========================================================================
# ៥. ENTRY POINT FOR SERVER EXECUTION
# =========================================================================
if __name__ == "__main__":
    import uvicorn
    print("\n" + "="*50)
    print("🚀 Chenla Smart Campus API Server is Running!")
    print("👉 View Swagger Documentation: http://localhost:8000/docs")
    print("="*50 + "\n")
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)