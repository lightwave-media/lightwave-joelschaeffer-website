## 1. Introduction & Goal

Launch a professional photography website ([joelschaeffer.com](http://joelschaeffer.com) photography section) featuring a curated portfolio gallery and integrated print shop. The primary goal is to establish a market presence for photography work by organizing the entire photography archive, finalizing 10-15 high-quality artworks, and creating a sustainable workflow for ongoing photo production and delivery.

**Problem it solves:** Currently, photography assets are disorganized across multiple locations (computer drives, NAS storage, physical negatives), making it impossible to effectively market or sell work. Without a systematic ingestion workflow, new photography continues to accumulate in an ad-hoc manner, preventing portfolio growth and website launch.

## 2. Business Value & Strategic Alignment

**Business Value:**

- **New Revenue Stream:** Print shop enables direct-to-consumer sales of fine art photography prints
- **Brand Positioning:** Establishes dual identity as both cinematographer and photographer, opening additional market opportunities
- **Portfolio Marketing:** Gallery provides visual showcase for attracting commercial photography clients
- **Asset Monetization:** Converts years of accumulated photography work into sellable products

**Strategic Alignment:**

- Aligns with LightWave Media's multi-platform strategy ([joelschaeffer.com](http://joelschaeffer.com), [photographyOS.io](http://photographyOS.io) future product)
- Supports "lean, AI-native creative business" model by establishing automated workflows early
- Complements cinematography services with still photography offerings
- Creates foundation for future photographyOS product development

**Who Benefits:**

- **Joel:** Professional photography presence, additional revenue stream, organized archive
- **Potential Clients:** Easy access to view and purchase photography work
- **Future Users:** Workflow systems tested here will inform photographyOS product

## 3. Scope

### 3.1. In Scope

- Complete organization of physical negatives (final 10%)
- Archive organization on NAS storage (structured folders, metadata)
- Computer hard drive cleanup and photography file consolidation
- Creation of photo ingestion SOP (scans + digital assets workflow)
- Execution of photo trips to generate new content (Oklahoma trip, Mammoth Lakes trip)
- Finalization of 10-15 high-quality artworks for portfolio (from current 4-5)
- Website structure planning (print shop + gallery architecture)
- Sprint Zero: Foundation and organization only

### 3.2. Out of Scope

- Website design and development (separate phase)
- E-commerce platform selection and integration (separate phase)
- Marketing campaign launch (separate phase)
- Social media strategy (separate phase)
- Ongoing content production beyond Sprint Zero trips
- photographyOS product development (future project)

## 4. Key Features / High-Level Requirements

- **Archive Organization System**
    - Description: Systematic organization of all photography assets across physical and digital media
    - Key requirements:
        - Folder structure for NAS storage (by year, project, format)
        - Negative organization system (binders, sleeves, labeling)
        - Computer drive cleanup protocol (consolidate scattered files)
        - Metadata tagging strategy (location, date, camera, format)
- **Photo Ingestion Workflow SOP**
    - Description: Documented, repeatable process for adding new photography to the archive
    - Key requirements:
        - Scan workflow (film negatives → digital files)
        - Digital asset import process (camera → storage)
        - File naming conventions
        - Quality control checkpoints
        - Backup procedures
        - Archive location mapping
- **Content Production Pipeline**
    - Description: Execute photo trips to generate portfolio-ready work
    - Key requirements:
        - Identify and execute 2 photo trips (Oklahoma, Mammoth Lakes)
        - Shot list planning for each trip
        - Equipment prep and checklists
        - Post-trip processing workflow
- **Portfolio Curation**
    - Description: Select, finalize, and prepare 10-15 artworks for website launch
    - Key requirements:
        - Selection criteria (quality, diversity, market appeal)
        - Final retouching and color grading
        - Print-ready file preparation (resolution, color space, formats)
        - Artwork metadata (title, description, print sizes, pricing considerations)

## 5. Success Metrics

- **Sprint Zero (Organization Foundation):**
    - ✅ 100% of negatives organized and catalogued
    - ✅ NAS storage structure implemented with 100% of digital archive migrated
    - ✅ Computer hard drives cleaned (0 orphaned photography files)
    - ✅ Photo ingestion SOP documented and tested
    - ✅ 2 photo trips completed (Oklahoma, Mammoth Lakes)
- **Portfolio Readiness:**
    - ✅ 10-15 finalized artworks ready for web (minimum 10, target 15)
    - ✅ All artworks have print-ready files (multiple size options)
    - ✅ Website structure plan documented (gallery layout + print shop flow)
- **Future Success (Post-Launch):**
    - Track: Monthly print sales revenue
    - Track: Gallery page views and engagement
    - Track: Commercial photography inquiries attributed to website

## 6. High-Level Technical Approach & Considerations

**Primary Systems Involved:**

- NAS Storage: Archive repository (organized folder structure)
- Computer: Working files and active projects
- Physical: Negative storage system (binders, archival sleeves)
- Future: [joelschaeffer.com](http://joelschaeffer.com) website (Next.js, print shop integration)

**Workflow Automation Opportunities:**

- File naming automation scripts
- Metadata extraction and tagging
- Batch processing for scans
- Image optimization pipeline (web vs. print formats)

**Key Technical Challenges:**

- Defining optimal folder taxonomy for diverse photography types (film, digital, commercial, personal)
- Color management workflow (scan → edit → web → print consistency)
- Balancing archive depth (keep everything) vs. portfolio focus (show only best)
- Print shop integration decision (Printful, Shopify, custom, etc.)

**Architecture Reference:**

- Related to [photographyOS.io](http://photographyOS.io) product planning (this tests workflow concepts)
- Integration point with [joelschaeffer.com](http://joelschaeffer.com) site rebuild

## 7. Dependencies

- **Equipment Access:** Film scanner, large format camera, Sony digital camera
- **Storage Capacity:** Sufficient NAS storage space for full archive migration
- **Trip Logistics:** Vehicle readiness (catalytic converter, headlight) for Mammoth trip
- **Weather/Timing:** Optimal conditions for photo trips (seasonal considerations)
- **Website Platform:** Future decision on e-commerce platform (doesn't block Sprint Zero)

## 8. Assumptions

- Current 4-5 finalized artworks are truly portfolio-ready (no rework needed)
- Negative organization is genuinely 90% complete (only final 10% remains)
- NAS storage has adequate capacity for entire archive
- Photo trips will yield portfolio-quality results (not guaranteed but expected)
- Film scanning services are available/accessible when needed
- Print shop integration can happen in a future phase (doesn't block launch)
- Workflow SOP can be documented without custom software tools initially

## 9. User Personas Involved

- **Persona 1: Joel (Photographer/Archive Manager)**
    - Primary user creating and managing the system
    - Needs: Fast ingestion workflow, easy retrieval, minimal maintenance overhead
    - Pain points: Current disorganization, time-consuming searches, duplicate files
- **Persona 2: Website Visitor/Potential Print Buyer**
    - Browsing portfolio gallery
    - Needs: High-quality images, easy navigation, clear print options and pricing
    - Goals: Discover work, purchase prints, contact for commissions
- **Persona 3: Commercial Photography Client**
    - Evaluating Joel's photography capabilities
    - Needs: Portfolio showcasing style, technical skill, range
    - Goals: Assess fit for project, make hiring decision

## 10. Open Questions / Risks

**Questions:**

1. What print shop platform best balances ease-of-integration with quality and margins? (Research needed)
2. Should physical print fulfillment be in-house or drop-ship? (Cost/quality trade-offs)
3. How to price fine art prints competitively while maintaining margin? (Market research needed)
4. What's the optimal portfolio size for website launch? (10 minimum, 15 target, but is more better?)
5. Should film scans happen now or after initial website launch? (Timeline vs. portfolio diversity)

**Risks:**

1. **Time Risk:** Archive organization could reveal more disorganization than estimated (the "final 10%" could expand)
2. **Quality Risk:** Photo trips may not yield portfolio-ready work (weather, locations, creative outcomes uncertain)
3. **Scope Creep Risk:** Perfectionism during artwork finalization could delay launch indefinitely
4. **Technical Risk:** Website integration complexity could be underestimated (especially print shop)
5. **Market Risk:** Uncertain demand for fine art prints (testing revenue model assumptions)

**Mitigation Strategies:**

- Time-box archive organization (set deadline, work within it)
- Execute multiple photo trips to increase odds of portfolio-quality results
- Define "done" criteria for artwork finalization (prevent endless tweaking)
- Launch with gallery first, add print shop in Phase 2 if needed (de-risk complexity)
- Start with conservative print pricing, adjust based on initial sales data

---

**Next Steps:**

- Review and approve this Epic structure
- Break down into User Stories for Sprint Zero execution
- Begin archive organization work (highest priority, longest duration)
- Schedule photo trips (time-sensitive, weather-dependent)

---

## 11. Related Documents & Resources

**Strategic Planning:**

- [Photography Business Development Strategy](https://www.notion.so/Photography-Business-Development-Strategy-057aa0bc234649ef941e986e04a40f99?pvs=21) - Overall business strategy for photography services

**Tasks & Deliverables:**

- [📋 Create SOP for photo ingestion workflow (scans + digital assets)](https://www.notion.so/Create-SOP-for-photo-ingestion-workflow-scans-digital-assets-4c25f3338a4044178ed4f6238f0295ad?pvs=21) - Key deliverable for Sprint Zero
- [Sprint Zero: Photography Archive Organization & Website Foundation](https://www.notion.so/Sprint-Zero-Photography-Archive-Organization-Website-Foundation-d9ab71e899ae44ed8ef1ed1554561e28?pvs=21) - Active sprint (Oct 17 - Nov 7, 2025)

**Website Planning:**

- Target domain: [joelschaeffer.com/photography](http://joelschaeffer.com/photography)
- Future product connection: [photographyOS.io](http://photographyOS.io) (workflow testing ground)

**Life Domain:**

- [photoOS](https://www.notion.so/photoOS-21539364b3be80bfb1ecf1605b2f1821?pvs=21) - All photography-related work streams

**Key Outcomes by Phase:**

### Sprint Zero Outcomes (Oct 17 - Nov 7, 2025)

1. **Organized Archive** → All photography assets catalogued and accessible
2. **Documented Workflow** → Photo ingestion SOP completed and tested
3. **Content Generation** → 2 photo trips executed, new portfolio content created
4. **Portfolio Expansion** → 10-15 finalized artworks ready for web display
5. **Website Plan** → Architecture and structure documented for development phase

### Phase 2 Outcomes (Future)

- Website design and development
- E-commerce platform integration
- Print shop launch
- Marketing campaign execution
- Gallery optimization based on analytics

### Long-term Outcomes

- Sustainable photography revenue stream
- Established commercial photography client pipeline
- Foundation for photographyOS product development
- Proven workflows for creative asset management