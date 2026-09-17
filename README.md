# smart_room_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


http://localhost:8000/docs   For backend


នៅក្នុងប្រព័ន្ធ Smart Room Management App នេះ ការបែងចែកតួនាទី (Roles) គឺដើម្បីឱ្យការងារមានភាពច្បាស់លាស់រវាង អ្នកគ្រប់គ្រង (Admin) និង អ្នកចុះរៀបចំផ្ទាល់ (Staff / អ្នករៀបចំបន្ទប់)។នេះជាមុខងារលម្អិតរបស់តួនាទីនីមួយៗ ដែលអ្នកអាចយកទៅធ្វើជាស្លាយ ឬសរសេរក្នុងឯកសារការពារបញ្ចប់ការសិក្សា (Project Defense) បាន៖១. មុខងារសម្រាប់ Admin (អ្នកគ្រប់គ្រងទូទៅ)Admin គឺជាអ្នកគ្រប់គ្រងជាន់ខ្ពស់ ដែលមានសិទ្ធិមើលការខុសត្រូវលើប្រព័ន្ធទាំងមូល៖ទិដ្ឋភាពទូទៅជាក់ស្តែង (Live Overview Dashboard)៖ មើលឃើញស្ថានភាពបន្ទប់ទាំងអស់ទាំង ៦០ ក្នុងពេលតែមួយ (ដឹងថាបន្ទប់ណាខ្លះទំនេរ, បន្ទប់ណាកំពុងប្រើ, និងបន្ទប់ណាខ្លះខូច)។ការគ្រប់គ្រងបន្ទប់ (Room Management)៖ អាចបង្កើតបន្ទប់ថ្មី, កែប្រែឈ្មោះបន្ទប់, ឬប្តូរប្រភេទបន្ទប់ (បន្ទប់រៀន, បន្ទប់ប្រជុំ, បន្ទប់កុំព្យូទ័រ...) ដោយមិនបាច់កែកូដ។គ្រប់គ្រងបុគ្គលិក (Staff Management)៖ បង្កើតគណនីឱ្យអ្នករៀបចំបន្ទប់ និងចាត់តាំង (Assign) ថាបុគ្គលិកណាម្នាក់ ត្រូវទទួលបន្ទុកមើលការខុសត្រូវបន្ទប់ណាខ្លះ (ឧ. បុគ្គលិក A មើលជាន់ទី ១, បុគ្គលិក B មើលជាន់ទី ២)។អនុម័តសំណើ (Request Approval)៖ ពិនិត្យមើល និងចុច អនុម័ត (Approve) ឬ បដិសេធ (Reject) រាល់សំណើសុំសម្ភារៈបន្ថែម ឬរបាយការណ៍ជួសជុលពីអ្នករៀបចំបន្ទប់។កំណត់កាលវិភាគរួម (Schedule Settings)៖ កំណត់ម៉ោងបើក/បិទប្រព័ន្ធរួម (ឧ. 5:00 AM បើក, 12:00 AM បិទ) និងមើលរបាយការណ៍ស្ថិតិសរុប (Analytics)។២. មុខងារសម្រាប់ អ្នករៀបចំបន្ទប់ (Staff / Room Manager)អ្នករៀបចំបន្ទប់ គឺជាអ្នកចុះអនុវត្តការងារផ្ទាល់នៅតាមបន្ទប់នីមួយៗ៖មើលបញ្ជីបន្ទប់របស់ខ្លួន (My Assigned Rooms)៖ ឃើញតែបន្ទប់ណាដែលខ្លួនត្រូវទទួលខុសត្រូវរៀបចំក្នុងវេនការងារប៉ុណ្ណោះ។បញ្ជាឧបករណ៍ និងផ្ទៀងផ្ទាត់ (IoT Device Checklist)៖បិទ/បើក ម៉ាស៊ីនត្រជាក់ (AC)បិទ/បើក អំពូលភ្លើង (Lighting)ពិនិត្យស្ថានភាព សោទ្វារ (Door Lock)ធ្វើបច្ចុប្បន្នភាពស្ថានភាពបន្ទប់ (Update Status)៖ ចុចប្តូរស្ថានភាពបន្ទប់ឱ្យ Admin ដឹងភ្លាមៗ៖រួចរាល់ (Ready)៖ រៀបចំរួច អាចឱ្យគ្រូ ឬសិស្សចូលរៀនបាន។កំពុងរៀបចំ (In Progress)៖ កំពុងបោសសម្អាត ឬរៀបចំតុ។ផ្អាក/ខូច (Out of Order)៖ បន្ទប់មានបញ្ហា មិនអាចប្រើបាន។រាយការណ៍បញ្ហា (Report Issues)៖ ប្រសិនបើឃើញមានឧបករណ៍ខូច (ឧ. អំពូលដាច់, ម៉ាស៊ីនត្រជាក់មិនត្រជាក់, តុបាក់) អាចសរសេររៀបរាប់ និងថតរូបផ្ញើទៅ Admin ភ្លាមៗ។ស្នើសុំសម្ភារៈ (Supply Request)៖ ស្នើសុំរបស់របរប្រើប្រាស់ក្នុងបន្ទប់បន្ថែម (ឧ. សុំសរសៃហ្វឺត, ដុំព្រីភ្លើង, ក្រដាសជូតមាត់) ទៅកាន់ Admin ឬឃ្លាំង។ស្កេន QR Code មុខបន្ទប់ (Quick Access)៖ គ្រាន់តែយកទូរសព្ទទៅស្កេន QR Code នៅមាត់ទ្វារបន្ទប់ នោះ App នឹងបើកទំព័របន្ទប់នោះឡើងមកភ្លាម ដើម្បីចំណេញពេលស្វែងរក។សង្ខេបភាពខុសគ្នា (Quick Summary):ចំណុចប្រៀបធៀបAdmin (អ្នកគ្រប់គ្រង)អ្នករៀបចំបន្ទប់ (Staff)សិទ្ធិមើលបន្ទប់ឃើញទាំងអស់ (៦០ បន្ទប់)ឃើញតែបន្ទប់ដែលខ្លួនត្រូវរៀបចំការងារចម្បងត្រួតពិនិត្យរួម, អនុម័តសំណើ, បង្កើតបន្ទប់បើក/បិទភ្លើង ម៉ាស៊ីនត្រជាក់, Update ស្ថានភាពបន្ទប់ការរាយការណ៍ទទួលរបាយការណ៍ និងអនុម័តផ្ញើរបាយការណ៍បញ្ហា និងស្នើសុំសម្ភារៈ

========================================
Run code 

cd backend 

python main.py

http://localhost:8000/docs


flutter run -d chrome


================================