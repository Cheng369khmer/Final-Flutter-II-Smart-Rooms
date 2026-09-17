from fastapi import FastAPI, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime

app = FastAPI(
    title="Chenla Smart Campus - Smart Room App API",
    description="Backend API សម្រាប់គ្រប់គ្រងបន្ទប់ បុគ្គលិក វត្តមាន និងសំណើសម្ភារៈ",
    version="1.0.0"
)

# ====================================================
# 1. CORS CONFIGURATION (សំខាន់សម្រាប់ FLUTTER WEB)
# ====================================================
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # អនុញ្ញាតឱ្យ Flutter Web និង Mobile ហៅ API បាន
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ====================================================
# 2. PYDANTIC MODELS (ទម្រង់ទិន្នន័យ)
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

# ====================================================
# 3. IN-MEMORY DATABASE (ទិន្នន័យ Dynamic ដែលអាចកែពី Python)
# ====================================================

# បញ្ជីបុគ្គលិក (Staff Database)
staff_db: List[dict] = [
    {
        "id": "CLU0001",
        "name": "សុខុម ថាងចេង",
        "role": "សាស្ត្រាចារ្យ (អគារ A)",
        "shift": "វេនព្រឹក (7:00 AM - 11:00 AM)",
        "building": "អគារ A",
        "category": "អគារ A",
        "image": "lib/src/sokhom.tc.jpg"  # រូបភាពលោក សុខុម
    },
    {
        "id": "CLU0002",
        "name": "គង់ វណ្ណៈ",
        "role": "ផ្នែកបច្ចេកទេស (អគារ B)",
        "shift": "វេនព្រឹក (6:00 AM - 2:00 PM)",
        "building": "អគារ B",
        "category": "អគារ B",
        "image": None
    },
    {
        "id": "CLU0003",
        "name": "ម៉េង ស្រីពៅ",
        "role": "ផ្នែកអនាម័យ (អគារ C - HR)",
        "shift": "វេនរសៀល (1:00 PM - 9:00 PM)",
        "building": "អគារ C",
        "category": "អគារ C",
        "image": None
    },
    {
        "id": "CLU0004",
        "name": "លី វិសាល",
        "role": "ផ្នែកសោរ (អគារ C)",
        "shift": "វេនយប់ (4:00 PM - 12:00 AM)",
        "building": "អគារ C",
        "category": "អគារ C",
        "image": None
    },
    {
        "id": "CLU0005",
        "name": "ពៅ សំបូរ",
        "role": "ចំណតម៉ូតូ",
        "shift": "វេនព្រឹក (7:30 AM - 5:30 PM)",
        "building": "ចំណតម៉ូតូ",
        "category": "ចំណតម៉ូតូ",
        "image": None
    },
    {
        "id": "CLU0006",
        "name": "សាន វិចិត្រ",
        "role": "ចំណតម៉ូតូ",
        "shift": "វេនព្រឹក (7:30 AM - 5:30 PM)",
        "building": "ចំណតម៉ូតូ",
        "category": "ចំណតម៉ូតូ",
        "image": None
    },
    {
        "id": "CLU0007",
        "name": "ជា ពិសិដ្ឋ",
        "role": "ចំណតម៉ូតូ",
        "shift": "វេនយប់ (5:30 PM - 9:30 PM)",
        "building": "ចំណតម៉ូតូ",
        "category": "ចំណតម៉ូតូ",
        "image": None
    }
]

# បញ្ជីសំណើសម្ភារៈ និងជួសជុល (Requests Database)
requests_db: List[dict] = []

# ====================================================
# 4. API ENDPOINTS
# ====================================================

@app.get("/")
def read_root():
    return {
        "status": "online",
        "message": "Chenla Smart Campus API is running!",
        "timestamp": datetime.now().isoformat()
    }

# ----------------------------------------------------
# A. STAFF APIS (DYNAMIC)
# ----------------------------------------------------

# ១. ទាញយកបញ្ជីបុគ្គលិកទាំងអស់ (ហៅដោយ staff_list_screen.dart)
@app.get("/api/staff", response_model=List[StaffModel])
def get_all_staff():
    return staff_db

# ២. ទាញយកទិន្នន័យបុគ្គលិកម្នាក់តាមរយៈ ID
@app.get("/api/staff/{staff_id}", response_model=StaffModel)
def get_staff_by_id(staff_id: str):
    for staff in staff_db:
        if staff["id"].lower() == staff_id.lower():
            return staff
    raise HTTPException(status_code=404, detail="រកមិនឃើញបុគ្គលិកនេះទេ")

# ៣. បន្ថែមបុគ្គលិកថ្មី (Add new staff)
@app.post("/api/staff", response_model=StaffModel, status_code=status.HTTP_201_CREATED)
def create_staff(staff: StaffModel):
    # ពិនិត្យមើល ID ស្ទួន
    for existing in staff_db:
        if existing["id"].lower() == staff.id.lower():
            raise HTTPException(status_code=400, detail="ID បុគ្គលិកនេះមានរួចហើយ")
    
    new_staff = staff.model_dump()
    staff_db.append(new_staff)
    return new_staff

# ៤. កែប្រែទិន្នន័យបុគ្គលិក (Update staff)
@app.put("/api/staff/{staff_id}", response_model=StaffModel)
def update_staff(staff_id: str, updated_data: StaffModel):
    for index, staff in enumerate(staff_db):
        if staff["id"].lower() == staff_id.lower():
            staff_db[index] = updated_data.model_dump()
            return staff_db[index]
    raise HTTPException(status_code=404, detail="រកមិនឃើញបុគ្គលិកដើម្បីកែប្រែទេ")

# ៥. លុបបុគ្គលិក (Delete staff)
@app.delete("/api/staff/{staff_id}")
def delete_staff(staff_id: str):
    for index, staff in enumerate(staff_db):
        if staff["id"].lower() == staff_id.lower():
            deleted = staff_db.pop(index)
            return {"message": f"បានលុប {deleted['name']} ដោយជោគជ័យ"}
    raise HTTPException(status_code=404, detail="រកមិនឃើញបុគ្គលិកដើម្បីលុបទេ")

# ----------------------------------------------------
# B. REQUESTS APIS (ហៅដោយ dashboard_screen.dart)
# ----------------------------------------------------

# ទទួលសំណើសម្ភារៈ ឬជួសជុលពី Dialog ក្នុង Dashboard
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

# ----------------------------------------------------
# C. MOCK APIS សម្រាប់ ROOMS & ATTENDANCE
# ----------------------------------------------------

@app.get("/api/rooms")
def get_rooms():
    return [
        {"room_number": "A101", "building": "អគារ A", "status": "ទំនេរ", "is_cleaned": True},
        {"room_number": "A102", "building": "អគារ A", "status": "កំពុងរៀន", "is_cleaned": True},
        {"room_number": "B201", "building": "អគារ B", "status": "ទំនេរ", "is_cleaned": False},
        {"room_number": "C301", "building": "អគារ C", "status": "កំពុងរៀបចំ", "is_cleaned": False},
    ]

@app.get("/api/attendance/today")
def get_today_duty():
    return {
        "time": "05:00 AM",
        "title": "ត្រួតពិនិត្យ និងបើកបន្ទប់ទទួលបន្ទុក",
        "note": "កត់ត្រាវត្តមាន Check-in មុនចាប់ផ្ដើមការងារ"
    }

# ====================================================
# 5. ENTRY POINT FOR DIRECT EXECUTION
# http://127.0.0.1:8000/docs fastapi documentation
# ====================================================
if __name__ == "__main__":
    import uvicorn
    # ដំណើរការ Server លើ Port 8000
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)