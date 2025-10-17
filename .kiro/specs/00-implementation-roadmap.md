---
title: Mobile App Implementation Roadmap
priority: OVERVIEW
estimated_effort: 4-6 weeks
status: pending
dependencies: []
---

# ZENA Mobile App - Complete Implementation Roadmap

## Executive Summary

This roadmap outlines the complete implementation plan to achieve feature parity between the Zena web and mobile apps. Based on comprehensive analysis of both codebases, we've identified **70% of web features missing** in mobile.

**Total Effort:** 4-6 weeks (with 2-3 developers)  
**Critical Features:** 4 specs (blocking core functionality)  
**High Priority:** 1 spec (needed for complete flows)  
**Medium Priority:** 2 specs (improves UX)  
**Low Priority:** 1 spec (polish)

## Analysis Documents Reference

Before starting implementation, review these analysis documents:

1. **ANALYSIS_SUMMARY.md** - Executive summary of gaps
2. **FEATURE_COMPARISON_TABLE.md** - Detailed feature comparison (75 features)
3. **ZENA_CHAT_SYSTEM_ANALYSIS.md** - Complete technical analysis (2000+ lines)
4. **MOBILE_APP_IMPLEMENTATION_QUICK_START.md** - Quick reference guide
5. **MOBILE_APP_CRITICAL_CODE_EXAMPLES.md** - Ready-to-use code (1000+ lines)

## Implementation Specs Overview

### Phase 1: Critical Features (Week 1-2)

#### 1. File Upload System (3-4 days) - CRITICAL
**Spec:** `01-file-upload-system.md`

**Why Critical:** Property submission is impossible without video upload

**Deliverables:**
- Camera video recording
- Gallery video selection
- Supabase Storage integration
- File preview and validation
- Upload progress tracking

**Success Criteria:**
- ✅ Users can record/select property videos
- ✅ Videos upload to Supabase Storage
- ✅ Public URLs returned and sent to AI

#### 2. Tool Result Rendering (4-5 days) - CRITICAL
**Spec:** `02-tool-result-rendering.md`

**Why Critical:** Users cannot interact with AI responses without proper UI

**Deliverables:**
- 15+ specialized tool result cards
- Tool result widget factory
- Property, payment, submission cards
- Interactive buttons and actions

**Success Criteria:**
- ✅ All 15+ tool types render correctly
- ✅ Interactive elements work
- ✅ 90%+ visual parity with web

#### 3. Multi-Turn Workflows (3-4 days) - CRITICAL
**Spec:** `03-multi-turn-workflows.md`

**Why Critical:** 5-stage property submission requires state tracking

**Deliverables:**
- Submission state manager
- Workflow stage tracking
- State persistence
- Stage progress UI

**Success Criteria:**
- ✅ State persists across messages
- ✅ 5-stage workflow completes successfully
- ✅ Multiple submissions tracked simultaneously

### Phase 2: High Priority (Week 3)

#### 4. Contact Info Request Flow (1-2 days) - HIGH
**Spec:** `04-payment-status-polling.md` (updated - payment polling done by backend!)

**Why High Priority:** Contact requests incomplete without proper UI

**Deliverables:**
- Phone confirmation card
- Phone input card
- Contact info display card
- Payment error card with retry

**Success Criteria:**
- ✅ Phone confirmation UI works
- ✅ Contact info displays after payment
- ✅ Error messages show with retry option

**Note:** Backend handles all payment polling internally - mobile just displays results!

### Phase 3: Medium Priority (Week 4)

#### 5. Conversation Management (2-3 days) - MEDIUM
**Spec:** `05-conversation-management.md`

**Why Medium Priority:** Improves UX but not blocking

**Deliverables:**
- Conversation list screen
- Conversation switching
- Conversation search
- Conversation deletion

**Success Criteria:**
- ✅ Users can view all conversations
- ✅ Users can switch between conversations
- ✅ Conversations persist locally

#### 6. Message Persistence (2 days) - MEDIUM
**Spec:** `06-message-persistence.md`

**Why Medium Priority:** Improves reliability but not blocking

**Deliverables:**
- Message persistence service
- SQLite database setup
- Offline message queue
- Message sync service

**Success Criteria:**
- ✅ Messages persist after app restart
- ✅ Offline messages queue and send
- ✅ Tool results persist

### Phase 4: Polish (Week 5)

#### 7. UX Enhancements (2-3 days) - LOW
**Spec:** `07-ux-enhancements.md`

**Why Low Priority:** Nice to have, not blocking

**Deliverables:**
- Suggested queries
- Shimmer loading states
- Theme toggle
- Animations and transitions
- Accessibility improvements

**Success Criteria:**
- ✅ Suggested queries help new users
- ✅ Loading states are polished
- ✅ Theme toggle works
- ✅ App is accessible

## Week-by-Week Plan

### Week 1: File Upload + Tool Cards Foundation
**Days 1-2:** File Upload System
- Create file upload widget
- Integrate Supabase Storage
- Test on real devices

**Days 3-5:** Core Tool Result Cards
- Create tool result factory
- Implement property cards
- Implement payment cards
- Test tool result rendering

### Week 2: Complete Tool Cards + Workflows
**Days 1-2:** Remaining Tool Cards
- Implement submission cards
- Implement other tool cards
- Test all tool types

**Days 3-5:** Multi-Turn Workflows
- Create submission state manager
- Implement workflow tracking
- Test 5-stage submission

### Week 3: Contact Flow + Integration
**Days 1-2:** Contact Info Request UI
- Create phone confirmation card
- Create contact info card
- Create error card
- Test payment flow (backend handles polling!)

**Days 3-5:** Integration Testing
- Test complete property submission
- Test complete contact request
- Fix bugs

### Week 4: Medium Priority Features
**Days 1-2:** Conversation Management
- Create conversation list
- Implement switching
- Test navigation

**Days 3-4:** Message Persistence
- Implement persistence service
- Add offline support
- Test persistence

**Day 5:** Integration & Testing

### Week 5: Polish & Launch Prep
**Days 1-2:** UX Enhancements
- Add suggested queries
- Add loading states
- Add theme toggle

**Days 3-4:** Testing & Bug Fixes
- End-to-end testing
- Fix critical bugs
- Performance optimization

**Day 5:** Documentation & Handoff

## Resource Allocation

### With 2 Developers:
- **Developer 1:** File upload, payment polling, message persistence
- **Developer 2:** Tool result cards, workflows, conversation management
- **Both:** UX enhancements, testing, bug fixes

**Timeline:** 5 weeks

### With 3 Developers:
- **Developer 1:** File upload, payment polling
- **Developer 2:** Tool result cards (all 15+)
- **Developer 3:** Workflows, conversation management, persistence
- **All:** UX enhancements, testing

**Timeline:** 4 weeks

## Testing Strategy

### Unit Tests (Throughout)
- Test each service independently
- Test state management
- Test data parsing

### Widget Tests (Throughout)
- Test each UI component
- Test user interactions
- Test error states

### Integration Tests (Week 3-4)
- Test complete workflows
- Test end-to-end flows
- Test error handling

### Manual Tests (Week 4-5)
- Test on real Android devices
- Test on real iOS devices
- Test with real M-Pesa
- Test offline scenarios

## Risk Mitigation

### High Risk Items:
1. **File Upload on iOS** - Camera permissions, file formats
   - Mitigation: Test early on real iOS device
   
2. **M-Pesa Payment Testing** - Need real M-Pesa for testing
   - Mitigation: Backend handles polling, mobile just displays results
   
3. **State Persistence** - Data loss, sync conflicts
   - Mitigation: Implement backup and recovery

### Medium Risk Items:
1. **Performance** - Large message lists, image loading
   - Mitigation: Implement pagination, lazy loading
   
2. **Offline Support** - Message queue, sync conflicts
   - Mitigation: Test offline scenarios thoroughly

## Implementation Status

### ✅ Completed
- [x] **File Upload System (Spec 01)** - 95% complete
  - ✅ FileUploadService with Supabase Storage integration
  - ✅ File upload bottom sheet with camera/gallery
  - ✅ Message input with file attachments
  - ✅ Chat provider with upload state management
  - ⚠️ Needs minor fix: Append file URLs to message text

### 🔄 In Progress
- [ ] **Tool Result Rendering (Spec 02)** - 10% complete
  - ✅ Basic property card exists
  - ❌ Tool result widget factory needed
  - ❌ 14+ specialized tool cards needed
  - ❌ Interactive buttons and actions needed

### 📋 Not Started
- [ ] **Multi-Turn Workflows (Spec 03)** - 0% complete
- [ ] **Contact Info Request Flow (Spec 04)** - 0% complete
- [ ] **Conversation Management (Spec 05)** - 0% complete
- [ ] **Message Persistence (Spec 06)** - 0% complete
- [ ] **UX Enhancements (Spec 07)** - 0% complete

## Success Metrics

### Must Have (Phase 1-2):
- [x] Users can upload property videos (95% - needs URL fix)
- [ ] Users can see all tool results with proper UI (10% - basic property card only)
- [ ] Users can complete 5-stage property submission (0% - needs workflow state)
- [ ] Users can request contact info and pay via M-Pesa (0% - needs UI cards)

### Should Have (Phase 3):
- [ ] Users can manage multiple conversations (0%)
- [ ] Messages persist after app restart (0%)
- [ ] Offline messages queue and send (0%)

### Nice to Have (Phase 4):
- [ ] Suggested queries help new users (0%)
- [ ] Loading states are polished (0%)
- [ ] Theme toggle works (0%)
- [ ] App is accessible (0%)

### Should Have (Phase 3):
- [ ] Users can manage multiple conversations
- [ ] Messages persist after app restart
- [ ] Offline messages queue and send

### Nice to Have (Phase 4):
- [ ] Suggested queries help new users
- [ ] Loading states are polished
- [ ] Theme toggle works
- [ ] App is accessible

## Dependencies & Prerequisites

### Technical:
- ✅ Flutter SDK installed
- ✅ Supabase project configured
- ✅ M-Pesa test environment access
- ✅ Android/iOS development setup

### Backend:
- ✅ Chat API endpoints working
- ✅ Tool system implemented
- ✅ Supabase Storage bucket created
- ✅ M-Pesa integration working

### Design:
- ✅ UI designs for tool cards
- ✅ Design system/theme
- ✅ Icons and assets

## Getting Started

### Step 1: Review Analysis
Read all analysis documents in `MISSING MD/` folder

### Step 2: Set Up Environment
- Install dependencies
- Configure environment variables
- Set up test devices

### Step 3: Start with Phase 1
Begin with `01-file-upload-system.md` spec

### Step 4: Follow Specs
Implement each spec in order, testing as you go

### Step 5: Integrate & Test
Test complete workflows after each phase

## Notes

- **DO NOT SKIP FILE UPLOAD** - Everything depends on it
- **TEST ON REAL DEVICES** - Camera, M-Pesa need real devices
- **FOLLOW WEB PATTERNS** - Reuse proven UI/UX patterns
- **TEST INCREMENTALLY** - Don't wait until end to test
- **DOCUMENT AS YOU GO** - Update docs with learnings

## Support & Resources

### Code Examples:
- `MOBILE_APP_CRITICAL_CODE_EXAMPLES.md` - 1000+ lines of ready-to-use code

### Web Reference:
- `zena/app/chat/` - Frontend implementation
- `zena/app/api/chat/` - Backend implementation
- `zena/lib/tools/` - Tool implementations

### Mobile Reference:
- `zena_mobile_app/lib/` - Current mobile implementation
- Each spec file has detailed requirements

## Conclusion

This roadmap provides a clear path to feature parity between web and mobile apps. By following the specs in order and testing incrementally, the mobile app will be fully functional in 4-6 weeks.

**Ready to start? Begin with Spec 01: File Upload System!**

---

**Last Updated:** October 17, 2025  
**Status:** Ready for Implementation  
**Next Action:** Review analysis documents, then start Spec 01
