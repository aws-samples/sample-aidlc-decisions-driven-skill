# Stray Animal Management System – ระบบจัดการสัตว์จรจัด

## Language / ภาษา

- **Document language**: Thai (ภาษาไทย)
- **Spec / Design / Tasks**: Thai
- **Code & comments**: English

## Background

กรุงเทพมหานครและเทศบาลต่าง ๆ มีปัญหาสัตว์จรจัด (สุนัข/แมว) จำนวนมาก ซึ่งส่งผลต่อสุขอนามัย ความปลอดภัยของประชาชน และสวัสดิภาพสัตว์ ต้องการระบบดิจิทัลสำหรับบริหารจัดการสัตว์จรจัดอย่างเป็นระบบ ตั้งแต่การลงทะเบียน ติดตามสุขภาพ ทำหมัน ฉีดวัคซีน ไปจนถึงการหาบ้านใหม่ (adoption) โดยเปิดให้ประชาชนมีส่วนร่วมในการแจ้งเบาะแส ดูแล และรับเลี้ยง

## Problem Statement

- ไม่มีฐานข้อมูลกลางของสัตว์จรจัดในพื้นที่ ไม่รู้จำนวนและที่อยู่ที่แท้จริง
- การทำหมัน/ฉีดวัคซีนไม่ทั่วถึง เพราะไม่รู้ว่าตัวไหนทำแล้ว/ยังไม่ทำ
- ประชาชนไม่มีช่องทางแจ้งปัญหาสัตว์จรจัดที่สะดวกและติดตามผลได้
- ขั้นตอนรับเลี้ยง (adoption) ยุ่งยาก ไม่มี platform กลางจับคู่คนกับสัตว์
- สัตว์ที่ถูกรับเลี้ยงแล้วไม่มีระบบติดตามหลัง adoption
- งบประมาณจำกัด ต้องจัดสรรทรัพยากรอย่างมีประสิทธิภาพ
- ขาดข้อมูลสำหรับวางนโยบาย (จำนวนสัตว์จรจัดเพิ่ม/ลดเท่าไหร่)

## Goals

1. สร้างฐานข้อมูลกลางสัตว์จรจัดที่สามารถระบุตัวตนสัตว์แต่ละตัวได้
2. ให้ประชาชนมีส่วนร่วมผ่านการแจ้งพบเห็น / รายงานปัญหา (crowdsourcing)
3. ติดตามสถานะสุขภาพ การทำหมัน และการฉีดวัคซีนของสัตว์แต่ละตัว
4. สร้างระบบ adoption ที่จับคู่คนกับสัตว์ได้ง่ายและติดตามหลังรับเลี้ยงได้
5. ให้ข้อมูล analytics สำหรับวางนโยบายและจัดสรรงบประมาณ
6. ลดจำนวนสัตว์จรจัดอย่างมีมนุษยธรรม (TNR — Trap, Neuter, Return + Adoption)

## Scope

### In Scope

- **Animal Registry** – ฐานข้อมูลสัตว์จรจัด (รูปถ่าย, ลักษณะ, พิกัด, สถานะ, ประวัติสุขภาพ)
- **Citizen Reporting** – ประชาชนแจ้งพบสัตว์จรจัด/บาดเจ็บ/อันตราย พร้อมรูป+พิกัด, ติดตามสถานะ
- **Health & Medical Records** – บันทึกทำหมัน, วัคซีน, การรักษา, กำหนดการนัดหมาย
- **Adoption System** – profile สัตว์, screening ผู้รับเลี้ยง, matching, follow-up หลังรับเลี้ยง
- **Community Features** – community feeder, อาสาสมัคร, foster, บริจาค, lost & found
- **Operations Management** – จัดทีม TNR, กำหนดเส้นทาง, จัดการ shelter, นัดสัตวแพทย์
- **Analytics & Dashboard** – heatmap สัตว์จรจัด, อัตราทำหมัน, adoption rate, trend, budget

### Out of Scope

- สัตว์จรจัดประเภทอื่น (นก, กระต่าย ฯลฯ) — เฉพาะสุนัขและแมว
- ระบบจัดการคลินิก/โรงพยาบาลสัตว์
- E-commerce (ขายอุปกรณ์สัตว์เลี้ยง)
- Pet insurance
- Integration กับ microchip reader hardware

## Key Assumptions

1. ใช้ภาพถ่ายเป็นหลักในการระบุตัวตนสัตว์ (ลักษณะเด่น, สี, markings)
2. ประชาชนสามารถแจ้งผ่าน LINE OA หรือ web app ได้
3. มีสัตวแพทย์อาสาหรือคลินิกพันธมิตรสำหรับทำหมัน/ฉีดวัคซีน
4. เทศบาล/กทม. เป็นผู้ดูแลระบบหลัก
5. เริ่มต้นในพื้นที่นำร่อง 5-10 เขตใน กทม.
6. สัตว์จรจัดที่ทำหมันแล้วจะถูก ear-tip เป็นสัญลักษณ์

## Functional Requirements

### FR-01: Animal Registration & Identification
- ลงทะเบียนสัตว์จรจัด (สุนัข/แมว) พร้อมรูปถ่าย, ลักษณะ, พิกัด, นิสัย
- Auto-generated Animal ID
- Duplicate detection จากรูปถ่าย (image similarity)
- แก้ไข/update ข้อมูลได้ตลอด

### FR-02: Citizen Reporting
- แจ้งผ่าน web app / LINE OA
- ประเภท: พบตัวใหม่, บาดเจ็บ/ป่วย, ก้าวร้าว, ฝูงเพิ่มจำนวน, ถูกทารุณกรรม
- แนบรูป + ปักหมุดพิกัด + ระบุความเร่งด่วน
- Workflow: รับเรื่อง → assign ทีม → ดำเนินการ → แจ้งผลกลับผู้แจ้ง
- Gamification ให้คะแนนผู้ช่วยเหลือ

### FR-03: Health & Sterilization Tracking
- บันทึก medical record ต่อตัว (วัคซีน, ทำหมัน, รักษา)
- กำหนดการวัคซีนครั้งถัดไป (auto-remind)
- TNR Campaign management: วางแผนพื้นที่, นับ target vs actual, บันทึกผล
- สถิติอัตราการทำหมันแยกตามเขต

### FR-04: Adoption System
- Animal profile สำหรับรับเลี้ยง (รูป, นิสัย, สุขภาพ, เหมาะกับสภาพแวดล้อมแบบไหน)
- ผู้สนใจลงทะเบียน + แบบสอบถาม screening
- Matching: แนะนำสัตว์ที่เหมาะกับ lifestyle
- Adoption process: สนใจ → สมัคร → นัดพบ → ทดลองเลี้ยง → ยืนยัน
- Post-adoption follow-up (1 สัปดาห์, 1 เดือน, 3 เดือน)

### FR-05: Community & Volunteer
- Community feeder: ลงทะเบียนจุดให้อาหาร, check-in, รายงานสถานะ
- อาสาสมัคร: ลงทะเบียน + ทักษะ, รับ assignment, บันทึกชั่วโมง, badge/certificate
- Foster: รับดูแลชั่วคราวระหว่างรอ adoption
- บริจาค: เงิน, สิ่งของ, sponsor สัตว์ตัวใดตัวหนึ่ง

### FR-06: Map & Area Management
- แผนที่แสดง: ตำแหน่งสัตว์จรจัด (heatmap), จุดให้อาหาร, shelter/คลินิก, พื้นที่ TNR
- แบ่งโซนรับผิดชอบตามเขต/แขวง
- มอบหมายทีมดูแลต่อโซน, กำหนด target ทำหมัน

### FR-07: Admin & Operations
- Dashboard: จำนวนสัตว์ในระบบ, cases & สถานะ, TNR progress, adoption rate, budget
- Workflow: assign tasks ให้ทีม/อาสาสมัคร, track completion, resource allocation
- Reporting: monthly report ต่อเขต, KPI tracking, export data

## Non-Functional Requirements

- **Performance**: page load < 3s, map rendering < 2s, รองรับ 50,000+ registered animals
- **Usability**: ใช้งานง่ายสำหรับประชาชนทั่วไป, mobile-first, ภาษาไทย, แจ้งเบาะแสได้ 3 ขั้นตอน
- **Security & Privacy**: ข้อมูลผู้รับเลี้ยงเป็นความลับ, ผู้แจ้ง anonymous ได้, PDPA compliant, role-based access
- **Scalability**: เริ่มนำร่อง 5-10 เขต → ขยายทั่ว กทม. → ทั่วประเทศ, multi-tenant ready
- **Availability**: uptime > 99.5%, กรณีเร่งด่วน process 24/7, offline capable สำหรับ field staff

## Success Metrics

| Metric | Target |
|--------|--------|
| Registered animals (Year 1) | > 10,000 ตัว |
| Sterilization rate (พื้นที่นำร่อง) | > 70% |
| Adoption success rate (ไม่ถูกส่งคืน) | > 80% |
| Citizen reports resolved | > 85% ภายใน 72 ชม. |
| Active volunteers | > 500 คน |
| Community feeders registered | > 200 จุด |
| Stray population change (Year 2) | ลดลง > 15% |
| Post-adoption follow-up completion | > 90% |

## Target Users

| User | Role | Primary Need |
|------|------|-------------|
| ประชาชนทั่วไป | แจ้งพบสัตว์จรจัด/ปัญหา | แจ้งง่าย, ติดตามผลได้ |
| ผู้ต้องการรับเลี้ยง | หาสัตว์มาเลี้ยง | ดู profile สัตว์, สมัครรับเลี้ยงง่าย |
| Community feeder | ดูแลสัตว์จรจัดในพื้นที่ | ลงทะเบียนจุดดูแล, report สถานะ |
| อาสาสมัคร | ช่วยจับ/ขนส่ง/foster | รับ assignment, บันทึกงาน |
| สัตวแพทย์อาสา | ทำหมัน/ฉีดวัคซีน/รักษา | ดู schedule, บันทึก medical record |
| เจ้าหน้าที่เทศบาล/กทม. | บริหารจัดการ | Dashboard, reports, จัดสรรทรัพยากร |
| NGO / มูลนิธิ | สนับสนุนการดำเนินงาน | ข้อมูล, ประสานงาน adoption |
