require 'spec_helper'

describe Mongoid::CategorizedCounterCache do

  let(:company) { Company.create }

  context 'when creating record' do

    it 'should set count for the matched category' do
      staff = Staff.create company: company, gender: :male

      company.reload
      expect(company.staffs_count).to eq(1)
      expect(company.staffs_male_count).to eq(1)
      expect(company.staffs_female_count).to eq(0)
    end

    it 'should increase count for the matched category' do
      company.set staffs_count: 5
      company.set staffs_male_count: 3
      company.set staffs_female_count: 2

      staff = Staff.create company: company, gender: :male

      company.reload
      expect(company.staffs_count).to eq(6)
      expect(company.staffs_male_count).to eq(4)
      expect(company.staffs_female_count).to eq(2)
    end
  end

  context 'when updating record' do

    let(:another_company) { Company.create }

    it 'should decrease count from original record and increase count on new record' do
      staff = Staff.create company: company, gender: :male

      company.set staffs_count: 5
      company.set staffs_male_count: 3
      company.set staffs_female_count: 2
      another_company.set staffs_count: 50
      another_company.set staffs_male_count: 30
      another_company.set staffs_female_count: 20

      staff.update_attributes company: another_company

      company.reload
      another_company.reload
      expect(company.staffs_count).to eq(4)
      expect(company.staffs_male_count).to eq(2)
      expect(company.staffs_female_count).to eq(2)
      expect(another_company.staffs_count).to eq(51)
      expect(another_company.staffs_male_count).to eq(31)
      expect(another_company.staffs_female_count).to eq(20)
    end

    it 'should decrease count from original record if new record is empty' do
      staff = Staff.create company: company, gender: :male

      company.set staffs_count: 5
      company.set staffs_male_count: 3
      company.set staffs_female_count: 2

      staff.update_attributes company: nil

      company.reload
      expect(company.staffs_count).to eq(5)    # mongoid `counter_cache` issue: it wont decrease if you update record to nil
      expect(company.staffs_male_count).to eq(2)
      expect(company.staffs_female_count).to eq(2)
    end
  end

  context 'when destroying record' do

    it 'should decrease count from the destroyed record' do
      staff = Staff.create company: company, gender: :male

      company.set staffs_count: 5
      company.set staffs_male_count: 3
      company.set staffs_female_count: 2

      staff.destroy

      company.reload
      expect(company.staffs_count).to eq(4)
      expect(company.staffs_male_count).to eq(2)
      expect(company.staffs_female_count).to eq(2)
    end
  end
end
