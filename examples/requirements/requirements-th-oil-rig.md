# Predictive Maintenance for Oil Rig with Local LLM – Business Requirements

## Language / ภาษา

- **Document language**: Thai (ภาษาไทย)
- **Spec / Design / Tasks**: Thai
- **Code & comments**: English

## Background

บริษัทดำเนินการขุดเจาะน้ำมันและก๊าซธรรมชาติ มีแท่นขุดเจาะ (Oil Rig) หลายแท่น ทั้ง Offshore และ Onshore แต่ละแท่นมีอุปกรณ์สำคัญที่ทำงานตลอด 24/7 ภายใต้สภาวะที่รุนแรง ต้องการระบบบำรุงรักษาเชิงคาดการณ์ (Predictive Maintenance) เพื่อลด unplanned downtime ที่มีต้นทุนสูงมาก (ค่าใช้จ่าย $500K–$1M/วัน สำหรับ offshore rig ที่หยุดทำงาน) และลดความเสี่ยงด้านความปลอดภัยและสิ่งแวดล้อม

ระบบต้องสามารถ monitor แท่นขุดเจาะหลายแท่นได้จากศูนย์ควบคุม (Central Control Room) ในเฟสแรกจะใช้ **ข้อมูลจำลอง (Simulated Data)** เนื่องจากยังไม่มีการติดตั้ง IoT hardware/software จริง และใช้ **Local LLM** ในการวิเคราะห์และคาดการณ์ความผิดปกติ

## Problem Statement

- ไม่สามารถ monitor แท่นขุดเจาะหลายแท่นจากจุดเดียวได้ ขาดภาพรวมสถานะอุปกรณ์ทั้งองค์กร
- อุปกรณ์ขุดเจาะเกิด unplanned breakdown สูญเสียรายได้มหาศาล ($500K–$1M/วัน)
- ความเสี่ยงด้านความปลอดภัย — อุปกรณ์บางชิ้น (เช่น BOP) อาจนำไปสู่อุบัติเหตุร้ายแรงหรือ blowout
- ความเสี่ยงด้านสิ่งแวดล้อม — การรั่วไหลอาจทำให้เกิดมลพิษทางทะเล
- การบำรุงรักษาแบบ reactive มีต้นทุนสูงมาก โดยเฉพาะ offshore ที่ logistics ซับซ้อน
- ไม่มีระบบเตือนล่วงหน้า ทำให้ไม่สามารถเตรียมอะไหล่และช่างล่วงหน้าได้
- ยังไม่มี IoT infrastructure จริง จึงต้องพิสูจน์ concept ด้วยข้อมูลจำลองก่อน

## Goals

1. สร้างระบบ Predictive Maintenance prototype สำหรับ Oil Rig ที่ใช้ Local LLM วิเคราะห์ข้อมูลเซนเซอร์จำลอง
2. รองรับการ monitor แท่นขุดเจาะหลายแท่นจากศูนย์ควบคุม (Multi-rig monitoring)
3. จำลองข้อมูล IoT sensor ที่สะท้อนพฤติกรรมอุปกรณ์ขุดเจาะจริง
4. ให้ LLM คาดการณ์ความเสี่ยงของอุปกรณ์และแนะนำแผนซ่อมบำรุง
5. สร้าง Digital Twin แบบจำลองเบื้องต้นของแท่นขุดเจาะ
6. เตรียมสถาปัตยกรรมให้พร้อมเชื่อมต่อ IoT hardware จริงในอนาคต

## Scope

### In Scope

- **Multi-Rig Management** – จัดการแท่นขุดเจาะหลายแท่นจาก centralized dashboard
- **Data Simulation Module** – จำลองข้อมูลเซนเซอร์ของอุปกรณ์ขุดเจาะ 4 ประเภท:
  - **Mud Pump**: pressure, flow rate, stroke rate, vibration, temperature
  - **Top Drive**: torque, RPM, vibration, temperature, current draw
  - **BOP (Blowout Preventer)**: hydraulic pressure, accumulator pressure, response time, temperature
  - **Drawworks**: brake temperature, line tension, drum speed, vibration
- **Local LLM Integration** – ใช้ local LLM วิเคราะห์ pattern ของข้อมูลเซนเซอร์
- **Anomaly Detection** – ตรวจจับค่าผิดปกติจากข้อมูลจำลอง
- **Failure Prediction** – คาดการณ์ Remaining Useful Life (RUL) ของอุปกรณ์
- **Maintenance Recommendation** – แนะนำแผนซ่อมบำรุง พร้อมอะไหล่ที่ต้องเตรียม
- **Basic Digital Twin** – แสดงสถานะอุปกรณ์แบบ real-time
- **Alert System** – แจ้งเตือนจัดลำดับตาม safety impact

### Out of Scope

- การติดตั้ง IoT hardware/sensor จริงบนแท่นขุดเจาะ
- การเชื่อมต่อกับระบบ SCADA/DCS จริง
- Mobile application
- Integration กับระบบ ERP/CMMS ที่มีอยู่
- Well control / drilling parameter optimization
- การจัดการ crew scheduling

## Key Assumptions

1. ใช้ Local LLM (เช่น Ollama) สำหรับการพัฒนาและทดสอบ
2. ข้อมูลจำลองมี pattern สะท้อนพฤติกรรมจริง:
   - Normal operation ภายใต้โหลดต่าง ๆ (tripping, drilling, circulating)
   - Gradual degradation (เช่น mud pump liner wear)
   - Sudden anomaly (เช่น BOP hydraulic leak)
   - Environmental impact (คลื่นลม, อุณหภูมิ)
3. ผู้ใช้งานหลักคือ Drilling Engineer, Maintenance Engineer, และ Rig Manager
4. อุปกรณ์ที่จำลองเป็นอุปกรณ์ที่มี criticality สูงและมีผลต่อ safety มากที่สุด

## Functional Requirements

### FR-01: Multi-Rig Management
- ลงทะเบียนและจัดการข้อมูล rig หลายแท่น (ชื่อ, ประเภท, ที่ตั้ง, สถานะการดำเนินงาน)
- Dashboard ภาพรวมทุก rig พร้อมสถานะสุขภาพอุปกรณ์
- Drill-down เข้าไปดูรายละเอียดแต่ละ rig
- เปรียบเทียบ KPI ระหว่าง rig (downtime, anomaly rate, NPT)

### FR-02: Data Simulation Engine
- สร้างข้อมูลเซนเซอร์จำลองแบบ time-series สำหรับอุปกรณ์ 4 ประเภท
- จำลองได้ทั้งสถานการณ์ปกติและผิดปกติ
- แยก operating condition ตาม rig และ mode (drilling/tripping/idle)
- ปรับ parameter ได้ (ความถี่ anomaly, ระดับ noise)

### FR-03: Local LLM Analysis
- ส่งข้อมูลเซนเซอร์ให้ LLM วิเคราะห์และตอบกลับ:
  - ระดับความเสี่ยง (Low / Medium / High / Critical)
  - ประเภทความผิดปกติที่คาด
  - Root cause analysis
  - คำแนะนำซ่อมบำรุง + อะไหล่ที่ต้องเตรียม
  - Remaining Useful Life (RUL)
  - Safety impact assessment

### FR-04: Anomaly Detection & Alert
- ตรวจจับค่าเกินขอบเขต (threshold-based) และ pattern ผิดปกติ (LLM-based)
- จัดลำดับ alert ตาม safety criticality, production impact, environmental risk
- แสดงระดับความรุนแรง (Green / Yellow / Orange / Red)

### FR-05: Maintenance Scheduling
- แนะนำตารางซ่อมบำรุงตาม prediction
- คำนึงถึง offshore logistics lead time และ drilling window
- แนะนำอะไหล่ที่ต้องเตรียม

### FR-06: Digital Twin Visualization
- แผนผังอุปกรณ์ของ rig แบบ schematic
- สถานะ real-time, กราฟ time-series, prediction timeline
- สถานะการดำเนินงาน (drilling/tripping/standby)

### FR-07: Reporting & Analytics
- สรุปสถานะรายวัน/รายสัปดาห์
- History ของ anomaly, predicted vs actual comparison
- NPT report และ cost savings summary

## Non-Functional Requirements

- **Performance**: real-time streaming ≥ 1 data point/วินาที/อุปกรณ์, LLM response < 30s
- **Safety & Security**: encryption, authentication, safety-critical alert redundancy, audit trail
- **Extensibility**: พร้อมเปลี่ยนเป็น real IoT data, เพิ่ม rig/อุปกรณ์ได้ง่าย, เปลี่ยน LLM model ได้
- **Usability**: ใช้งานง่าย, color-coded status ตาม industry standard
- **Reliability**: zero missed critical alerts, fallback เป็น threshold-based ถ้า LLM ไม่ตอบ

## Success Metrics

| Metric | Target |
|--------|--------|
| Anomaly detection accuracy (simulated) | > 85% |
| False positive rate | < 15% |
| LLM prediction response time | < 30s |
| Critical alert miss rate | 0% |
| ครอบคลุมอุปกรณ์ | 4 ประเภท |
| NPT reduction (projected) | > 20% |

## Target Users

| User | Role | Primary Need |
|------|------|-------------|
| Drilling Engineer | วางแผนและควบคุมการขุดเจาะ | รู้ล่วงหน้าว่าอุปกรณ์ไหนจะเสีย |
| Maintenance Engineer | ดูแลอุปกรณ์ประจำ rig | เตรียมอะไหล่และวางแผนซ่อมล่วงหน้า |
| Rig Manager | บริหารจัดการ rig | ลด NPT, จัดสรรทรัพยากร |
| HSE Officer | ดูแลความปลอดภัย | ตรวจสอบ safety-critical equipment |
| Operations Manager (Shore-based) | ดูแลภาพรวมหลาย rig | เปรียบเทียบ performance ระหว่าง rig |
