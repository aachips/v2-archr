<template>
  <div class="marketplace-page">
    <!-- Breadcrumb bar (only for need-review) -->
    <div v-if="subView === 'need-review'" class="marketplace-page__breadcrumb">
      <button class="marketplace-page__breadcrumb-btn" @click="goBack">
        <i class="fas fa-arrow-left"></i> Back to Marketplace
      </button>
      <span class="marketplace-page__breadcrumb-sep">/</span>
      <span class="marketplace-page__breadcrumb-current">Repair Need Review</span>
    </div>

    <!-- Marketplace Home (4 browse options) -->
    <MarketplaceHome v-if="subView !== 'need-review'" @browse="onBrowse" />

    <!-- Tabbed marketplace sections (always shown unless on need-review) -->
    <div v-if="subView !== 'need-review'" class="marketplace-page__tabs">
      <!-- Tab bar -->
      <div class="marketplace-page__tab-bar">
        <button
          v-for="tab in tabs"
          :key="tab.id"
          class="marketplace-page__tab"
          :class="{ 'marketplace-page__tab--active': activeTab === tab.id }"
          @click="activeTab = tab.id"
        >
          {{ tab.label }}
          <span v-if="tab.badge" class="marketplace-page__badge">{{ tab.badge }}</span>
        </button>
      </div>

      <!-- Tab content -->
      <div class="marketplace-page__content">
        <YourClaims
          v-if="activeTab === 'your-claims'"
          :claims="yourClaims"
          :current-org="currentOrg"
          @release-claim="onReleaseClaim"
          @renew-claim="onRenewClaim"
        />
        <UnclaimedNeeds
          v-if="activeTab === 'unclaimed'"
          :needs="unclaimedNeeds"
          :current-org="currentOrg"
          @claim-need="onClaimNeed"
        />
        <ClaimedByOrg
          v-if="activeTab === 'claimed-by-org'"
          :claims="claimedByOrgClaims"
          :current-org="currentOrg"
          @renew-claim="onRenewClaim"
          @release-claim="onReleaseClaim"
        />
        <MyReferrals
          v-if="activeTab === 'referrals'"
          :inbox="referralInbox"
          :outbox="referralOutbox"
          @open-application="onOpenApplication"
        />
        <CaseList
          v-if="activeTab === 'cases'"
          :cases="casesList"
          @open-case="onOpenCase"
        />
      </div>
    </div>

    <!-- Case Review (full page) -->
    <div v-if="subView === 'case-review' && selectedCase" class="marketplace-page__review">
      <CaseReviewPage
        :case-item="selectedCase"
        :application="selectedCase.application"
        :sow-line-items="selectedCase.sowLineItems || []"
        @back="goBackFromCase"
        @parse-sow="onParseSow"
      />
    </div>

    <!-- Repair Need Review (full page) -->
    <div v-if="subView === 'need-review' && selectedNeed" class="marketplace-page__review">
      <RepairNeedReview
        :need="selectedNeed"
        :claims="selectedNeedClaims"
        :current-org="currentOrg"
        @mark-met="onMarkMet"
        @edit-need="onEditNeed"
        @renew-claim="onRenewClaim"
        @release-claim="onReleaseClaim"
        @back="goBack"
      />
    </div>

    <!-- Refer Project Modal -->
    <ReferProjectModal
      :visible="showReferModal"
      :record-details="recordDetailsForReferral"
      :partners="partnerOrgs"
      :subcontractors="subcontractorList"
      @close="showReferModal = false"
      @submit="onSubmitReferral"
    />
  </div>
</template>

<script>
import MarketplaceHome from './marketplace/MarketplaceHome.vue';
import YourClaims from './marketplace/YourClaims.vue';
import UnclaimedNeeds from './marketplace/UnclaimedNeeds.vue';
import ClaimedByOrg from './marketplace/ClaimedByOrg.vue';
import MyReferrals from './marketplace/MyReferrals.vue';
import RepairNeedReview from './marketplace/RepairNeedReview.vue';
import ReferProjectModal from './marketplace/ReferProjectModal.vue';
import CaseList from './CaseList.vue';
import CaseReviewPage from './CaseReviewPage.vue';

/**
 * Marketplace — the Phase 2 Marketplace page.
 *
 * Sub-views:
 *   home        — welcome + 4 browse options
 *   your-claims — cases your org has claimed
 *   unclaimed   — unclaimed repair needs table
 *   claimed-by-org — needs claimed by your org
 *   referrals   — referral inbox/outbox
 *   need-review — detail page for a repair need
 */
export default {
  name: 'Marketplace',
  components: {
    MarketplaceHome,
    YourClaims,
    UnclaimedNeeds,
    ClaimedByOrg,
    MyReferrals,
    RepairNeedReview,
    ReferProjectModal,
    CaseList,
    CaseReviewPage
  },
  props: {
    cases: { type: Array, default: function() { return []; } }
  },
  data: function() {
    return {
      activeTab: 'your-claims',
      selectedNeed: null,
      selectedNeedClaims: [],
      selectedCase: null,
      casesList: [],
      showReferModal: false,
      recordDetailsForReferral: '',
      // ============================================================
      // DUMMY DATA — Replace with real API calls when assessment flow is built
      // ============================================================
      yourClaims: [
        {
          id: 'claim-1',
          applicationId: 'app-1',
          applicantName: 'Eileen Bailey',
          placecode: '247-RIVERSIDE',
          submissionDate: '2026-09-15T10:30:00Z',
          claimDate: '2026-09-16T09:00:00Z',
          claimStatus: 'active',
          workflowStatus: 'assessed',
          claimOrganization: 'AHFH',
          imageUrl: '',
          repairNeeds: [
            { id: 'rn-1', trade: 'Roofing', description: 'Complete roof replacement, storm damage', triageScore: 9, estimatedCost: 18500, quotedCost: 17200 },
            { id: 'rn-2', trade: 'Carpentry', description: 'Replace flooring and rebuild south wall', triageScore: 7, estimatedCost: 12000, quotedCost: null }
          ],
          sowCreated: true,
          sowDate: '2026-09-20T14:00:00Z'
        },
        {
          id: 'claim-2',
          applicationId: 'app-2',
          applicantName: 'Marcus Johnson',
          placecode: '55-OAK-AVE',
          submissionDate: '2026-08-28T14:00:00Z',
          claimDate: '2026-08-29T11:30:00Z',
          claimStatus: 'expiring',
          workflowStatus: 'in-assessment',
          claimOrganization: 'AHFH',
          imageUrl: '',
          repairNeeds: [
            { id: 'rn-3', trade: 'Plumbing', description: 'Fix burst pipe in basement, replace water heater', triageScore: 8 }
          ]
        },
        {
          id: 'claim-3',
          applicationId: 'app-3',
          applicantName: 'Sarah Chen',
          placecode: '102-MAIN-ST',
          submissionDate: '2026-07-10T08:15:00Z',
          claimDate: '2026-07-11T10:00:00Z',
          claimStatus: 'active',
          workflowStatus: 'ready-for-contract',
          claimOrganization: 'AHFH',
          imageUrl: '',
          repairNeeds: [
            { id: 'rn-4', trade: 'Electrical', description: 'Rewire damaged circuits from flood', triageScore: 6, estimatedCost: 8500, quotedCost: 9200, actualCost: null },
            { id: 'rn-5', trade: 'Drywall', description: 'Replace ceiling and sheetrock materials', triageScore: 4, estimatedCost: 4200, quotedCost: 4500, actualCost: null }
          ],
          sowCreated: true,
          sowDate: '2026-09-18T10:00:00Z'
        }
      ],
      unclaimedNeeds: [
        { id: 'rn-6', trade: 'Roofing', description: 'Partial roof collapse, temporary tarp installed', triageScore: 10, applicationId: 'app-4', applicationName: 'Davis, R.', dateReceived: '2026-09-20T16:00:00Z', placecode: '88-PINE-RD', workflowStatus: 'assessment-ready' },
        { id: 'rn-7', trade: 'Plumbing', description: 'Sewer line backup, health hazard', triageScore: 9, applicationId: 'app-5', applicationName: 'Nguyen, T.', dateReceived: '2026-09-19T11:30:00Z', placecode: '33-ELM-LN', workflowStatus: 'assessment-ready' },
        { id: 'rn-8', trade: 'Carpentry', description: 'Structural beam replacement, house settling', triageScore: 8, applicationId: 'app-6', applicationName: 'Williams, K.', dateReceived: '2026-09-18T09:00:00Z', placecode: '15-BIRCH-WAY', workflowStatus: 'in-assessment' },
        { id: 'rn-9', trade: 'Foundation', description: 'Cracked foundation, water intrusion', triageScore: 7, applicationId: 'app-7', applicationName: 'Garcia, L.', dateReceived: '2026-09-17T14:45:00Z', placecode: '42-MAPLE-DR', workflowStatus: 'assessment-ready' },
        { id: 'rn-10', trade: 'HVAC', description: 'Replace furnace and ductwork', triageScore: 5, applicationId: 'app-8', applicationName: 'Thompson, J.', dateReceived: '2026-09-16T10:15:00Z', placecode: '77-CEDAR-CT', workflowStatus: 'assessment-ready' },
        { id: 'rn-11', trade: 'Painting', description: 'Interior repaint after mold remediation', triageScore: 2, applicationId: 'app-9', applicationName: 'Anderson, M.', dateReceived: '2026-09-14T08:30:00Z', placecode: '91-WALNUT-ST', workflowStatus: 'assessed' }
      ],
      claimedByOrgClaims: [
        { id: 'org-claim-1', trade: 'Roofing', description: 'Complete roof replacement, storm damage', applicationId: 'app-1', applicationName: 'Bailey, E.', dateClaimed: '2026-09-16T09:00:00Z', claimStatus: 'active', triageScore: 9, daysUntilExpiry: 75, workflowStatus: 'assessed', estimatedCost: 18500, quotedCost: 17200 },
        { id: 'org-claim-2', trade: 'Carpentry', description: 'Replace flooring and rebuild south wall', applicationId: 'app-1', applicationName: 'Bailey, E.', dateClaimed: '2026-09-16T09:00:00Z', claimStatus: 'active', triageScore: 7, daysUntilExpiry: 75, workflowStatus: 'assessed', estimatedCost: 12000, quotedCost: null },
        { id: 'org-claim-3', trade: 'Plumbing', description: 'Fix burst pipe in basement', applicationId: 'app-2', applicationName: 'Johnson, M.', dateClaimed: '2026-08-29T11:30:00Z', claimStatus: 'expiring', triageScore: 8, daysUntilExpiry: 8, workflowStatus: 'in-assessment', estimatedCost: 9500, quotedCost: null },
        { id: 'org-claim-4', trade: 'Electrical', description: 'Rewire damaged circuits from flood', applicationId: 'app-3', applicationName: 'Chen, S.', dateClaimed: '2026-07-11T10:00:00Z', claimStatus: 'active', triageScore: 6, daysUntilExpiry: 45, workflowStatus: 'ready-for-contract', estimatedCost: 8500, quotedCost: 9200 }
      ],
      referralInbox: [
        { id: 'ref-1', type: 'inbound', fromOrg: 'Community Housing Coalition', toOrg: 'AHFH', requestText: 'Roof assessment needed for elderly resident at 33-ELM-LN', scopeOfWork: 'Full roof inspection and estimate, temporary tarp if needed', applicationId: 'app-5', applicationName: 'Nguyen, T.', date: '2026-09-21T10:00:00Z', status: 'pending' },
        { id: 'ref-2', type: 'inbound', fromOrg: 'PODER Emma', toOrg: 'AHFH', requestText: 'Emergency plumbing — sewer backup at 88-PINE-RD', scopeOfWork: 'Sewer line repair, health hazard mitigation', applicationId: 'app-4', applicationName: 'Davis, R.', date: '2026-09-20T14:30:00Z', status: 'pending' }
      ],
      referralOutbox: [
        { id: 'ref-3', type: 'outbound', fromOrg: 'AHFH', toOrg: 'PODER Emma', requestText: 'Plumbing emergency at 55-OAK-AVE — org lacks capacity', scopeOfWork: 'Emergency pipe replacement, water heater install', applicationId: 'app-2', applicationName: 'Johnson, M.', date: '2026-09-18T09:00:00Z', status: 'accepted' }
      ],
      // Assessment bookmark — process TBD pending assessor data standardization
      assessmentNote: 'Assessment flow is pending. Assessor data collection process to be standardized.',
      partnerOrgs: [
        { id: 'hfh', name: 'Asheville Area Habitat for Humanity' },
        { id: 'chc', name: 'Community Housing Coalition' },
        { id: 'poder', name: 'PODER Emma' }
      ],
      subcontractorList: [
        { id: 'sc1', name: 'ABC Roofing Co.' },
        { id: 'sc2', name: 'WNC Plumbing LLC' }
      ]
    };
  },
  computed: {
    currentOrg: function() {
      return 'AHFH';
    },
    currentBreadcrumb: function() {
      var labels = {
        'your-claims': 'Your Claims',
        'unclaimed': 'Unclaimed Needs',
        'claimed-by-org': 'Claimed by My Org',
        'referrals': 'My Referrals',
        'need-review': 'Repair Need Review'
      };
      return labels[this.subView] || this.subView;
    },
    tabs: function() {
      return [
        { id: 'your-claims', label: 'Your Claims', badge: this.yourClaims.length || '' },
        { id: 'unclaimed', label: 'Unclaimed Needs', badge: this.unclaimedNeeds.length || '' },
        { id: 'claimed-by-org', label: 'Claimed by My Org' },
        { id: 'referrals', label: 'My Referrals' },
        { id: 'cases', label: 'Cases', badge: this.casesList.length || '' }
      ];
    }
  },
  methods: {
    goHome: function() {
      this.activeTab = 'your-claims';
      this.selectedNeed = null;
      this.selectedCase = null;
      this.subView = '';
    },
    goBack: function() {
      this.activeTab = 'your-claims';
      this.selectedNeed = null;
      this.subView = '';
    },
    goBackFromCase: function() {
      this.selectedCase = null;
      this.subView = '';
      this.activeTab = 'cases';
    },
    onOpenCase: function(caseItem) {
      this.selectedCase = caseItem;
      this.subView = 'case-review';
    },
    onParseSow: function(payload) {
      // Create cases from SOW line items
      var self = this;
      var newCases = payload.items.map(function(item, i) {
        return {
          id: 'case-' + Date.now() + '-' + i,
          placecode: self.selectedCase.placecode + '-' + item.taskName.substring(0, 10).replace(/\s/g, '-'),
          applicantName: self.selectedCase.applicantName,
          repairType: item.taskName,
          status: 'active',
          createdAt: new Date().toISOString(),
          organization: self.selectedCase.organization,
          applicationId: self.selectedCase.applicationId,
          sowLineItems: [item]
        };
      });

      this.casesList = this.casesList.concat(newCases);
      payload.done(newCases);
    },
    onBrowse: function(mode) {
      var map = {
        applications: 'your-claims',
        needs: 'unclaimed',
        trade: 'claimed-by-org',
        triage: 'unclaimed'
      };
      var tabId = map[mode] || 'your-claims';
      // Switch to the tab
      this.activeTab = tabId;
      // Scroll to the tabs section
      this.$nextTick(function() {
        var tabBar = document.querySelector('.marketplace-page__tab-bar');
        if (tabBar) tabBar.scrollIntoView({ behavior: 'smooth', block: 'start' });
      });
    },
    onReleaseClaim: function(claim) {
      // TODO: API call to release claim
      console.log('Release claim:', claim);
    },
    onRenewClaim: function(claim) {
      // TODO: API call to renew claim timer
      console.log('Renew claim:', claim);
    },
    onClaimNeed: function(need) {
      // TODO: API call to claim a repair need
      console.log('Claim need:', need);
    },
    onOpenApplication: function(appId) {
      this.$emit('open-application', appId);
    },
    onMarkMet: function(need) {
      console.log('Mark met:', need);
    },
    onEditNeed: function(need) {
      console.log('Edit need:', need);
    },
    onSubmitReferral: function(data) {
      // TODO: API call to create referral
      console.log('Submit referral:', data);
      this.showReferModal = false;
    }
  },
  watch: {
    activeTab: function(newVal) {
      if (newVal !== 'need-review') {
        // Track last visited tab for back navigation
      }
    }
  }
};
</script>

<style scoped>
.marketplace-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 24px 20px;
}

.marketplace-page__tabs {
  margin-top: 16px;
}

.marketplace-page__tab-bar {
  display: flex;
  border-bottom: 1px solid var(--color-border, #e5e7eb);
  background: var(--bg-surface-alt, #f8f9fa);
  border-radius: var(--border-radius, 8px) var(--border-radius, 8px) 0 0;
  overflow-x: auto;
}

.marketplace-page__tab {
  padding: 12px 20px;
  border: none;
  background: none;
  font-size: 0.85rem;
  font-weight: 500;
  color: var(--color-text-muted, #6b7280);
  cursor: pointer;
  white-space: nowrap;
  display: inline-flex;
  align-items: center;
  gap: 8px;
  border-bottom: 2px solid transparent;
  transition: color 0.2s, border-color 0.2s;
}
.marketplace-page__tab:hover {
  color: var(--color-text, #333);
}
.marketplace-page__tab--active {
  color: var(--color-primary, #2a5c82);
  font-weight: 600;
  border-bottom-color: var(--color-primary, #2a5c82);
  background: var(--bg-surface, #fff);
}

.marketplace-page__badge {
  display: inline-block;
  font-size: 0.7rem;
  font-weight: 700;
  background: var(--color-primary, #2a5c82);
  color: #fff;
  padding: 1px 7px;
  border-radius: 10px;
  min-width: 18px;
  text-align: center;
}

.marketplace-page__content {
  padding: 20px 0;
}

/* Breadcrumb */
.marketplace-page__breadcrumb {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 0;
  margin-bottom: 16px;
  font-size: 0.9rem;
}
.marketplace-page__breadcrumb-btn {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  background: none;
  border: none;
  color: var(--color-primary, #2a5c82);
  font-size: 0.9rem;
  font-weight: 500;
  cursor: pointer;
  padding: 4px 8px;
  border-radius: 4px;
}
.marketplace-page__breadcrumb-btn:hover {
  background: var(--bg-surface-alt, #f3f4f6);
}
.marketplace-page__breadcrumb-sep {
  color: var(--color-text-muted, #6b7280);
}
.marketplace-page__breadcrumb-current {
  color: var(--color-text, #333);
  font-weight: 600;
}

/* Review page wrapper */
.marketplace-page__review {
  padding: 20px 0;
}
</style>
