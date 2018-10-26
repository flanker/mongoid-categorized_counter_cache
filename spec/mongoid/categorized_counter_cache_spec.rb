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

  context 'category as prefix' do

    let(:company) { CategoryAsPrefix::Company.create }
    let(:user) { CategoryAsPrefix::User.create company: company, status: :active }

    it 'create user' do
      user

      company.reload
      expect(company.users_count).to eq(1)
      expect(company.active_users_count).to eq(1)
      expect(company.inactive_users_count).to eq(0)
    end

  end

  context 'category changed' do

    let(:company) { CategoryAsPrefix::Company.create }
    let(:user) { CategoryAsPrefix::User.create company: company, status: :active }

    before do
      user
      company.reload
    end

    it 'decrease the original count and increase the current count' do
      expect(company.active_users_count).to eq(1)
      expect(company.inactive_users_count).to eq(0)

      byebug
      user.update_attributes status: :inactive

      company.reload
      expect(company.active_users_count).to eq(0)
      expect(company.inactive_users_count).to eq(1)
    end
  end
end
