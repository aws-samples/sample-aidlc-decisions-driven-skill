# Online Election System – ระบบเลือกตั้งผู้ว่าฯ กทม. และ สก. ออนไลน์

## Language / ภาษา

- **Document language**: Thai (ภาษาไทย)
- **Spec / Design / Tasks**: Thai
- **Code & comments**: English

## Background

กรุงเทพมหานครต้องการพัฒนาระบบเลือกตั้งออนไลน์ (e-Voting) สำหรับการเลือกตั้ง **ผู้ว่าราชการกรุงเทพมหานคร** และ **สมาชิกสภากรุงเทพมหานคร (สก.)** เพื่อเพิ่มความสะดวกให้ประชาชน ลดต้นทุนการจัดการเลือกตั้ง และเพิ่มอัตราการมีส่วนร่วม (voter turnout) โดยระบบต้องมีความปลอดภัย โปร่งใส ตรวจสอบได้ และรองรับผู้มีสิทธิเลือกตั้งหลายล้านคน

## Problem Statement

- อัตราการออกมาใช้สิทธิ์ (voter turnout) ยังไม่ถึงเป้าหมาย เนื่องจากความไม่สะดวกในการเดินทางไปคูหา
- ประชาชนที่อยู่นอกพื้นที่ทะเบียนบ้านไม่สะดวกในการเดินทางกลับมาใช้สิทธิ์
- ต้นทุนการจัดเลือกตั้งสูง (คูหา, บุคลากร, วัสดุ, การนับคะแนน)
- การนับคะแนนใช้เวลานานและมีโอกาสผิดพลาดจาก human error
- ผู้พิการ/ผู้สูงอายุมีอุปสรรคในการเดินทางไปคูหา
- ขาดความโปร่งใสในกระบวนการนับคะแนน ประชาชนตรวจสอบได้ยาก

## Goals

1. สร้างระบบ e-Voting ที่ปลอดภัย โปร่งใส ตรวจสอบได้ สำหรับเลือกตั้งผู้ว่าฯ กทม. และ สก.
2. เพิ่ม voter turnout โดยให้ลงคะแนนได้จากทุกที่ผ่านอินเทอร์เน็ต
3. รองรับผู้มีสิทธิเลือกตั้งในเขต กทม. (ประมาณ 4-5 ล้านคน)
4. ลดต้นทุนและเวลาในการจัดการเลือกตั้ง
5. ให้ผลการเลือกตั้งที่รวดเร็วและแม่นยำ
6. รองรับ accessibility สำหรับผู้พิการและผู้สูงอายุ

## Scope

### In Scope

- **Voter Registration & Verification** – ตรวจสอบสิทธิ์จากทะเบียนราษฎร์, ยืนยันตัวตนด้วย Digital ID, ป้องกันลงคะแนนซ้ำ
- **Ballot System** – บัตรเลือกผู้ว่าฯ (1 คน) + บัตรเลือก สก. ตามเขต, ตัวเลือก "ไม่ประสงค์ลงคะแนน"
- **Voting Process** – เปิด-ปิดหีบตามเวลา, ลงคะแนนผ่าน web browser, review & confirm, ออก receipt
- **Vote Counting & Results** – นับคะแนนอัตโนมัติ real-time, แยกผลตามเขต, audit trail
- **Election Administration** – จัดการผู้สมัคร, เขตเลือกตั้ง, กำหนดวัน-เวลา, monitor real-time
- **Public Dashboard** – ผลคะแนน real-time, สถิติ turnout, แผนที่ กทม. แยกเขต

### Out of Scope

- การเลือกตั้งระดับชาติ (สส., สว.)
- การเลือกตั้งท้องถิ่นอื่นนอกจาก กทม.
- Physical voting (คูหาปกติ) — ระบบนี้เป็น online channel เพิ่มเติม
- การลงทะเบียนผู้สมัครรับเลือกตั้ง (ใช้ระบบ กกต. เดิม)
- Campaign management / หาเสียง
- การร้องเรียน/อุทธรณ์ผลเลือกตั้ง

## Key Assumptions

1. ระบบ e-Voting เป็น **ช่องทางเพิ่มเติม** จากคูหาเลือกตั้งปกติ (hybrid model)
2. ผู้มีสิทธิ์ต้องลงทะเบียนล่วงหน้าว่าจะลงคะแนนแบบ online (ป้องกันลงซ้ำ)
3. มีการเชื่อมต่อกับฐานข้อมูลทะเบียนราษฎร์ และ Digital ID (ThaiD / NDID)
4. กทม. มี 50 เขต, สก. เขตละ 1-3 คน (ตามจำนวนประชากร)
5. ผู้มีสิทธิเลือกตั้งประมาณ 4-5 ล้านคน, คาดว่า 30-50% จะเลือกใช้ช่องทาง online
6. ต้องผ่านการรับรองจาก กกต. และมีกรอบกฎหมายรองรับ

## Functional Requirements

### FR-01: Voter Registration & Eligibility Check
- ตรวจสอบสิทธิ์เลือกตั้ง (อายุ ≥ 18, มีชื่อในทะเบียนบ้าน กทม., ไม่ถูกเพิกถอนสิทธิ์)
- ลงทะเบียนใช้สิทธิ์ออนไลน์ล่วงหน้า พร้อมยืนยันตัวตน
- ตัดชื่อออกจากบัญชีรายชื่อคูหาปกติอัตโนมัติ

### FR-02: Identity Verification (วันเลือกตั้ง)
- Multi-factor authentication ก่อนลงคะแนน (Digital ID + biometric + OTP)
- Liveness detection ป้องกันใช้รูปถ่าย
- Lock account หลัง verify ผิดหลายครั้ง

### FR-03: Ballot & Voting Interface
- บัตรเลือกผู้ว่าฯ (เลือก 1 คน) และบัตรเลือก สก. ตามเขต
- แสดงข้อมูลผู้สมัคร (หมายเลข, ชื่อ, รูป, สังกัดพรรค)
- ตัวเลือก "ไม่ประสงค์ลงคะแนน"
- Review & confirm ก่อนส่ง (แก้ไขไม่ได้หลังยืนยัน)
- ออก voting receipt ที่ไม่เปิดเผยเนื้อหาบัตร

### FR-04: Vote Encryption & Submission
- End-to-end encryption: บัตรถูก encrypt ก่อนส่งออกจากเครื่องผู้ใช้
- แยก identity ออกจาก vote content (unlinkability)
- บันทึก encrypted vote ลง immutable log

### FR-05: Vote Counting & Results
- นับคะแนนอัตโนมัติหลังปิดหีบ ด้วย threshold decryption (ต้องใช้ key จากหลายฝ่ายรวมกัน)
- ผลคะแนน: ผู้ว่าฯ รวม กทม., สก. แยกตาม 50 เขต, turnout, บัตรไม่ประสงค์ลงคะแนน
- Verifiable results: ประชาชน verify vote ของตนถูกนับได้, ผู้สังเกตการณ์ verify ผลรวมได้

### FR-06: Audit & Transparency
- Audit trail ทุกขั้นตอน (registration, authentication, submission, counting)
- Public bulletin board แสดง encrypted votes (ตรวจสอบไม่ถูกเพิ่ม/ลบ)
- รองรับการตรวจสอบโดยหน่วยงานอิสระ
- Observer access สำหรับผู้สังเกตการณ์ (พรรค, NGO, สื่อ)

### FR-07: Election Administration
- สร้าง/จัดการ election event, เขตเลือกตั้ง, ข้อมูลผู้สมัคร
- Monitor real-time (turnout, system health, security events)
- Emergency controls (หยุดชั่วคราว, ขยายเวลา)

### FR-08: Public Results Dashboard
- Live update ขณะนับคะแนน (กราฟ, แผนที่ กทม. แยกเขต)
- Voter turnout statistics
- เปรียบเทียบกับการเลือกตั้งครั้งก่อน
- Export data สำหรับสื่อและนักวิจัย

## Non-Functional Requirements

- **Security**: end-to-end encryption, ballot secrecy (unlinkability), coercion resistance, threshold decryption, DDoS protection, security audit โดยหน่วยงานอิสระ
- **Performance & Scalability**: รองรับ 500,000+ concurrent users, voting transaction < 5s, 99.99% uptime วันเลือกตั้ง
- **Reliability**: zero vote loss, failover < 30s, geographic redundancy, resume capability
- **Accessibility**: WCAG 2.1 AA, screen reader, keyboard navigation, high contrast, font size adjustable
- **Legal & Compliance**: สอดคล้องกับ พ.ร.บ. เลือกตั้ง, ผ่านรับรอง กกต., PDPA compliant
- **Usability**: ใช้งานง่ายสำหรับทุกวัย, ขั้นตอนลงคะแนนไม่เกิน 5 นาที, มีคู่มือ/video

## Success Metrics

| Metric | Target |
|--------|--------|
| System uptime (วันเลือกตั้ง) | > 99.99% |
| Voting transaction time | < 5 วินาที |
| Concurrent users supported | > 500,000 |
| Voter turnout increase (vs physical only) | +10-15% |
| Online voter adoption rate | > 30% ของผู้มีสิทธิ์ |
| Zero vote loss | 100% |
| Successful identity verification rate | > 95% |
| Security incidents | 0 critical |

## Target Users

| User | Role | Primary Need |
|------|------|-------------|
| ประชาชนผู้มีสิทธิเลือกตั้ง | ลงคะแนน | สะดวก ปลอดภัย จากที่ไหนก็ได้ |
| ผู้สูงอายุ/ผู้พิการ | ลงคะแนน | Accessible, ไม่ต้องเดินทาง |
| ผู้ที่อยู่นอกพื้นที่ | ลงคะแนนจากต่างจังหวัด/ต่างประเทศ | ใช้สิทธิ์ได้โดยไม่ต้องเดินทางกลับ |
| เจ้าหน้าที่ กกต. | บริหารจัดการเลือกตั้ง | Monitor, จัดการ, ประกาศผล |
| ผู้สังเกตการณ์ | ตรวจสอบความโปร่งใส | Verify กระบวนการถูกต้อง |
| สื่อมวลชน | รายงานผล | ดูผลคะแนน real-time, export data |
