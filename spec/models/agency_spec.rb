require 'rails_helper'

RSpec.describe Agency, type: :model do
  # Create factory-like objects for testing
  subject { create(:agency, code: 'TEST', name: 'Test Agency') }
  let(:vmcott) { create(:agency, code: 'VMCOTT', name: 'Vehicle Maintenance Company of Trinidad and Tobago') }
  let(:ptsc) { create(:agency, code: 'PTSC', name: 'Public Transport Service Corporation') }

  describe 'Validations' do
    context 'presence validations' do
      it { should validate_presence_of(:code) }
      it { should validate_presence_of(:name) }
    end

    context 'uniqueness validations' do
      it { should validate_uniqueness_of(:code) }
    end

    describe 'code uniqueness' do
      let!(:existing_agency) { create(:agency, code: 'DUP') }

      it 'prevents creating duplicate code' do
        duplicate = build(:agency, code: 'DUP')
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:code]).to include('has already been taken')
      end
    end

    describe 'name presence' do
      it 'is invalid without a name' do
        agency = build(:agency, name: nil)
        expect(agency).not_to be_valid
      end
    end

    describe 'code presence' do
      it 'is invalid without a code' do
        agency = build(:agency, code: nil)
        expect(agency).not_to be_valid
      end
    end
  end

  describe 'Associations' do
    describe 'has_many associations' do
      it { should have_many(:users).dependent(:destroy) }
      it { should have_many(:vehicles).dependent(:destroy) }
      it { should have_many(:drivers).dependent(:destroy) }
      it { should have_many(:alerts).dependent(:destroy) }
      it { should have_many(:routes).dependent(:destroy) }
      it { should have_many(:cashier_sessions).dependent(:destroy) }
      it { should have_many(:accounts).dependent(:destroy) }
      it { should have_many(:agency_settings).dependent(:destroy) }
      it { should have_many(:job_templates).dependent(:destroy) }
      it { should have_many(:maintenance_requests).dependent(:destroy) }
      it { should have_many(:quotations).dependent(:destroy) }
    end

    describe 'has_many through associations' do
      it { should have_many(:fare_rules).through(:routes) }
      it { should have_many(:pos_transactions).through(:cashier_sessions) }
    end

    describe 'dependent: :destroy behavior' do
      before do
        create(:user, agency: subject)
        subject.vehicles.create(attributes_for(:vehicle))
      end

      it 'destroys associated users when agency is destroyed' do
        expect {
          subject.destroy
        }.to change(User, :count).by(-1)
      end

      it 'destroys associated vehicles when agency is destroyed' do
        expect {
          subject.destroy!
        }.to change(Vehicle, :count).by(-1)
      end
    end
  end

  describe 'Scopes' do
    before do
      create(:agency, code: 'VMCOTT', name: 'VMCOTT')
      create(:agency, code: 'PTSC', name: 'PTSC')
      create(:agency, code: 'TTPS', name: 'TTPS')
      create(:agency, code: 'TTDF', name: 'TTDF')
      create(:agency, code: 'FIRE', name: 'FIRE')
      create(:agency, code: 'HEALTH', name: 'HEALTH')
      create(:agency, code: 'EDUCATION', name: 'EDUCATION')
    end

    describe '.active' do
      it 'returns agencies with codes' do
        agencies = described_class.active
        expect(agencies.count).to eq(7)
        expect(agencies.all? { |a| a.code.present? }).to be true
      end
    end

    describe '.central' do
      it 'returns only VMCOTT agency' do
        agencies = described_class.central
        expect(agencies.count).to eq(1)
        expect(agencies.first.code).to eq('VMCOTT')
      end
    end

    describe '.subordinate' do
      it 'returns all agencies except VMCOTT' do
        agencies = described_class.subordinate
        expect(agencies.count).to eq(6)
        expect(agencies.pluck(:code)).not_to include('VMCOTT')
      end
    end

    describe '.transport' do
      it 'returns only PTSC agency' do
        agencies = described_class.transport
        expect(agencies.count).to eq(1)
        expect(agencies.first.code).to eq('PTSC')
      end
    end

    describe '.security' do
      it 'returns TTPS and TTDF agencies' do
        agencies = described_class.security
        expect(agencies.count).to eq(2)
        expect(agencies.pluck(:code)).to match_array(['TTPS', 'TTDF'])
      end
    end

    describe '.emergency' do
      it 'returns only FIRE agency' do
        agencies = described_class.emergency
        expect(agencies.count).to eq(1)
        expect(agencies.first.code).to eq('FIRE')
      end
    end

    describe '.ministry' do
      it 'returns HEALTH and EDUCATION agencies' do
        agencies = described_class.ministry
        expect(agencies.count).to eq(2)
        expect(agencies.pluck(:code)).to match_array(['HEALTH', 'EDUCATION'])
      end
    end

    describe '.with_pos' do
      it 'returns agencies with POS system' do
        agencies = described_class.with_pos
        expect(agencies.count).to eq(1)
        expect(agencies.first.code).to eq('PTSC')
      end
    end

    describe '.can_process_quotations' do
      it 'returns only VMCOTT agency' do
        agencies = described_class.can_process_quotations
        expect(agencies.count).to eq(1)
        expect(agencies.first.code).to eq('VMCOTT')
      end
    end

    describe '.can_create_job_templates' do
      it 'returns only VMCOTT agency' do
        agencies = described_class.can_create_job_templates
        expect(agencies.count).to eq(1)
        expect(agencies.first.code).to eq('VMCOTT')
      end
    end
  end

  describe 'Class Methods' do
    before do
      described_class.destroy_all
      create(:agency, code: 'VMCOTT', name: 'VMCOTT')
      create(:agency, code: 'PTSC', name: 'PTSC')
      create(:agency, code: 'TEST', name: 'TEST')
    end

    describe '.central_agency' do
      it 'returns the VMCOTT agency' do
        central = described_class.central_agency
        expect(central).not_to be_nil
        expect(central.code).to eq('VMCOTT')
      end
    end

    describe '.subordinate_agencies' do
      it 'returns all agencies except VMCOTT' do
        subordinates = described_class.subordinate_agencies
        expect(subordinates.count).to eq(2)
        expect(subordinates.pluck(:code)).to match_array(['PTSC', 'TEST'])
      end
    end

    describe '.transport_agencies' do
      it 'returns PTSC agencies' do
        transports = described_class.transport_agencies
        expect(transports.count).to eq(1)
        expect(transports.first.code).to eq('PTSC')
      end
    end

    describe '.security_agencies' do
      before do
        create(:agency, code: 'TTPS', name: 'TTPS')
        create(:agency, code: 'TTDF', name: 'TTDF')
      end

      it 'returns TTPS and TTDF agencies' do
        securities = described_class.security_agencies
        expect(securities.count).to eq(2)
        expect(securities.pluck(:code)).to match_array(['TTPS', 'TTDF'])
      end
    end

    describe '.emergency_agencies' do
      before do
        create(:agency, code: 'FIRE', name: 'FIRE')
      end

      it 'returns FIRE agency' do
        emergencies = described_class.emergency_agencies
        expect(emergencies.count).to eq(1)
        expect(emergencies.first.code).to eq('FIRE')
      end
    end

    describe '.ministry_agencies' do
      before do
        create(:agency, code: 'HEALTH', name: 'HEALTH')
        create(:agency, code: 'EDUCATION', name: 'EDUCATION')
      end

      it 'returns HEALTH and EDUCATION agencies' do
        ministries = described_class.ministry_agencies
        expect(ministries.count).to eq(2)
        expect(ministries.pluck(:code)).to match_array(['HEALTH', 'EDUCATION'])
      end
    end

    describe '.seed_all_agencies' do
      it 'creates or updates all predefined agencies' do
        described_class.destroy_all
        expect {
          described_class.seed_all_agencies
        }.to change(Agency, :count).by(8)
      end

      it 'creates VMCOTT agency with correct attributes' do
        described_class.destroy_all
        described_class.seed_all_agencies
        vmcott = described_class.find_by(code: 'VMCOTT')
        expect(vmcott).not_to be_nil
        expect(vmcott.name).to eq('Vehicle Maintenance Company of Trinidad and Tobago')
      end

      it 'creates all 8 predefined agencies' do
        described_class.destroy_all
        described_class.seed_all_agencies
        expected_codes = %w[VMCOTT PTSC TTPS TTDF FIRE HEALTH EDUCATION JOTT]
        created_codes = described_class.pluck(:code)
        expect(created_codes).to match_array(expected_codes)
      end
    end
  end

  describe 'Instance Methods - Type Checks' do
    describe '#central?' do
      it 'returns true for VMCOTT' do
        expect(vmcott.central?).to be true
      end

      it 'returns false for non-VMCOTT agencies' do
        expect(ptsc.central?).to be false
        expect(subject.central?).to be false
      end
    end

    describe '#transport?' do
      it 'returns true for PTSC' do
        expect(ptsc.transport?).to be true
      end

      it 'returns false for non-PTSC agencies' do
        expect(vmcott.transport?).to be false
        expect(subject.transport?).to be false
      end
    end

    describe '#police?' do
      let(:ttps) { create(:agency, code: 'TTPS', name: 'TTPS') }

      it 'returns true for TTPS' do
        expect(ttps.police?).to be true
      end

      it 'returns false for non-TTPS agencies' do
        expect(vmcott.police?).to be false
      end
    end

    describe '#defence?' do
      let(:ttdf) { create(:agency, code: 'TTDF', name: 'TTDF') }

      it 'returns true for TTDF' do
        expect(ttdf.defence?).to be true
      end

      it 'returns false for non-TTDF agencies' do
        expect(vmcott.defence?).to be false
      end
    end

    describe '#fire?' do
      let(:fire) { create(:agency, code: 'FIRE', name: 'FIRE') }

      it 'returns true for FIRE' do
        expect(fire.fire?).to be true
      end

      it 'returns false for non-FIRE agencies' do
        expect(vmcott.fire?).to be false
      end
    end

    describe '#health?' do
      let(:health) { create(:agency, code: 'HEALTH', name: 'HEALTH') }

      it 'returns true for HEALTH' do
        expect(health.health?).to be true
      end

      it 'returns false for non-HEALTH agencies' do
        expect(vmcott.health?).to be false
      end
    end

    describe '#education?' do
      let(:education) { create(:agency, code: 'EDUCATION', name: 'EDUCATION') }

      it 'returns true for EDUCATION' do
        expect(education.education?).to be true
      end

      it 'returns false for non-EDUCATION agencies' do
        expect(vmcott.education?).to be false
      end
    end

    describe '#judiciary?' do
      let(:jott) { create(:agency, code: 'JOTT', name: 'JOTT') }

      it 'returns true for JOTT' do
        expect(jott.judiciary?).to be true
      end

      it 'returns false for non-JOTT agencies' do
        expect(vmcott.judiciary?).to be false
      end
    end

    describe '#ministry?' do
      let(:health) { create(:agency, code: 'HEALTH', name: 'HEALTH') }
      let(:education) { create(:agency, code: 'EDUCATION', name: 'EDUCATION') }

      it 'returns true for HEALTH' do
        expect(health.ministry?).to be true
      end

      it 'returns true for EDUCATION' do
        expect(education.ministry?).to be true
      end

      it 'returns false for non-ministry agencies' do
        expect(vmcott.ministry?).to be false
        expect(ptsc.ministry?).to be false
      end
    end
  end

  describe 'Instance Methods - Configuration' do
    describe '#display_name' do
      it 'returns configured name for known agencies' do
        expect(vmcott.display_name).to eq('Vehicle Maintenance Company of Trinidad and Tobago')
      end

      it 'falls back to name attribute if not in configuration' do
        expect(subject.display_name).to eq('Test Agency')
      end

      it 'falls back to code if name is nil' do
        subject.update(name: nil)
        expect(subject.display_name).to eq('TEST')
      end
    end

    describe '#short_name' do
      it 'returns configured short name for known agencies' do
        expect(vmcott.short_name).to eq('VMCOTT')
        expect(ptsc.short_name).to eq('PTSC')
      end

      it 'falls back to code for unknown agencies' do
        expect(subject.short_name).to eq('TEST')
      end
    end

    describe '#agency_config' do
      it 'returns configuration hash for known agencies' do
        config = vmcott.agency_config
        expect(config).to be_a(Hash)
        expect(config[:name]).to eq('Vehicle Maintenance Company of Trinidad and Tobago')
      end

      it 'returns empty hash for unknown agencies' do
        config = subject.agency_config
        expect(config).to be_a(Hash)
        expect(config).to be_empty
      end
    end

    describe '#color_scheme' do
      it 'returns configured color scheme for known agencies' do
        expect(vmcott.color_scheme).to eq('blue')
        expect(ptsc.color_scheme).to eq('green')
      end

      it 'returns default color for unknown agencies' do
        expect(subject.color_scheme).to eq('primary')
      end
    end

    describe '#icon' do
      it 'returns configured icon for known agencies' do
        expect(vmcott.icon).to eq('gear-wide')
        expect(ptsc.icon).to eq('bus-front')
      end

      it 'returns default icon for unknown agencies' do
        expect(subject.icon).to eq('building')
      end
    end

    describe '#gradient_colors' do
      it 'returns gradient colors for known agencies' do
        gradient = vmcott.gradient_colors
        expect(gradient).to be_a(Hash)
        expect(gradient[:start]).to eq('#1a237e')
        expect(gradient[:end]).to eq('#283593')
      end

      it 'returns default gradients for unknown agencies' do
        gradient = subject.gradient_colors
        expect(gradient[:start]).to eq('#0d6efd')
        expect(gradient[:end]).to eq('#0d6efd')
      end
    end

    describe '#has_pos_system?' do
      it 'returns true for PTSC' do
        expect(ptsc.has_pos_system?).to be true
      end

      it 'returns false for VMCOTT' do
        expect(vmcott.has_pos_system?).to be false
      end

      it 'returns false for unknown agencies' do
        expect(subject.has_pos_system?).to be false
      end
    end

    describe '#can_process_quotations?' do
      it 'returns true for VMCOTT' do
        expect(vmcott.can_process_quotations?).to be true
      end

      it 'returns false for non-VMCOTT agencies' do
        expect(ptsc.can_process_quotations?).to be false
        expect(subject.can_process_quotations?).to be false
      end
    end

    describe '#can_create_job_templates?' do
      it 'returns true for VMCOTT' do
        expect(vmcott.can_create_job_templates?).to be true
      end

      it 'returns false for non-VMCOTT agencies' do
        expect(ptsc.can_create_job_templates?).to be false
        expect(subject.can_create_job_templates?).to be false
      end
    end

    describe '#role' do
      it 'returns configured role for known agencies' do
        expect(vmcott.role).to eq('central')
        expect(ptsc.role).to eq('transport')
      end

      it 'returns default role for unknown agencies' do
        expect(subject.role).to eq('subordinate')
      end
    end
  end

  describe 'Instance Methods - Helpers' do
    describe '#css_class' do
      it 'returns CSS class based on color scheme' do
        expect(vmcott.css_class).to eq('agency-blue')
        expect(ptsc.css_class).to eq('agency-green')
      end

      it 'returns default class for unknown agencies' do
        expect(subject.css_class).to eq('agency-primary')
      end
    end

    describe '#badge_color' do
      let(:fire) { create(:agency, code: 'FIRE', name: 'FIRE') }
      let(:health) { create(:agency, code: 'HEALTH', name: 'HEALTH') }
      let(:ttps) { create(:agency, code: 'TTPS', name: 'TTPS') }

      it 'returns primary badge color for central agency' do
        expect(vmcott.badge_color).to eq('primary')
      end

      it 'returns success badge color for transport agency' do
        expect(ptsc.badge_color).to eq('success')
      end

      it 'returns danger badge color for security agency' do
        expect(ttps.badge_color).to eq('danger')
      end

      it 'returns warning badge color for emergency agency' do
        expect(fire.badge_color).to eq('warning')
      end

      it 'returns info badge color for ministry agency' do
        expect(health.badge_color).to eq('info')
      end

      it 'returns secondary for unknown role' do
        expect(subject.badge_color).to eq('secondary')
      end
    end
  end

  describe 'Instance Methods - Analytics' do
    describe '#total_vehicles' do
      before do
        subject.vehicles.create(attributes_for(:vehicle))
        subject.vehicles.create(attributes_for(:vehicle))
        vmcott.vehicles.create(attributes_for(:vehicle))
      end

      it 'returns count of vehicles for the agency' do
        expect(subject.total_vehicles).to eq(2)
        expect(vmcott.total_vehicles).to eq(1)
      end

      it 'returns 0 for agency with no vehicles' do
        new_agency = create(:agency, code: 'NEW', name: 'New Agency')
        expect(new_agency.total_vehicles).to eq(0)
      end
    end
  end

  describe 'AGENCY_CONFIGURATIONS constant' do
    it 'is frozen' do
      expect(described_class::AGENCY_CONFIGURATIONS).to be_frozen
    end

    it 'contains all predefined agencies' do
      expected_codes = %w[VMCOTT PTSC TTPS TTDF FIRE HEALTH EDUCATION JOTT]
      expect(described_class::AGENCY_CONFIGURATIONS.keys).to match_array(expected_codes)
    end

    it 'contains valid configuration for each agency' do
      Agency::AGENCY_CONFIGURATIONS.each do |code, config|
        expect(config).to include(:name, :short_name, :color_scheme, :icon, :role)
      end
    end
  end
end
