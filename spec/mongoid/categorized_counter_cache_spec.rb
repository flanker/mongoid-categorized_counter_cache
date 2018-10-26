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

    let(:staff) { staff = Staff.create name: 'anna', company: company, gender: :male }

    before do
      staff

      company.set staffs_count: 5
      company.set staffs_male_count: 3
      company.set staffs_female_count: 2
    end

    context 'company has not been changed' do

      it 'does nothing if category not changed' do
        staff.update_attributes name: 'elsa'

        company.reload
        expect(company.staffs_count).to eq(5)
        expect(company.staffs_male_count).to eq(3)
        expect(company.staffs_female_count).to eq(2)
      end

      it 'increase the current category counter and decrease the original counter if category has been changed' do
        staff.update_attributes gender: :female

        company.reload
        expect(company.staffs_count).to eq(5)
        expect(company.staffs_male_count).to eq(2)
        expect(company.staffs_female_count).to eq(3)
      end

      it 'handles if category changed to empty/nil' do
        staff.update_attributes gender: nil

        company.reload
        expect(company.staffs_count).to eq(5)
        expect(company.staffs_male_count).to eq(2)
        expect(company.staffs_female_count).to eq(2)
      end

      it 'handles if category changed from empty/nil' do
        a_staff = Staff.create name: 'anna', company: company, gender: ''

        company.set staffs_count: 5
        company.set staffs_male_count: 3
        company.set staffs_female_count: 2

        a_staff.update_attributes gender: :male

        company.reload
        expect(company.staffs_count).to eq(5)
        expect(company.staffs_male_count).to eq(4)
        expect(company.staffs_female_count).to eq(2)
      end
    end

    context 'company has been changed' do

      let(:another_company) { Company.create }

      context 'category has not been changed' do

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

        it 'should decrease count of original record if new record is empty' do
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

        it 'should increase count of current record if original record is empty' do
          staff = Staff.create company: nil, gender: :male

          company.set staffs_count: 5
          company.set staffs_male_count: 3
          company.set staffs_female_count: 2

          staff.update_attributes company: company

          company.reload
          expect(company.staffs_count).to eq(6)
          expect(company.staffs_male_count).to eq(4)
          expect(company.staffs_female_count).to eq(2)
        end
      end

      context 'category has also been changed' do

        it 'should decrease original category count of original record and increase current category count of new record' do
          staff = Staff.create company: company, gender: :male

          company.set staffs_count: 5
          company.set staffs_male_count: 3
          company.set staffs_female_count: 2
          another_company.set staffs_count: 50
          another_company.set staffs_male_count: 30
          another_company.set staffs_female_count: 20

          staff.update_attributes company: another_company, gender: :female

          company.reload
          another_company.reload
          expect(company.staffs_count).to eq(4)
          expect(company.staffs_male_count).to eq(2)
          expect(company.staffs_female_count).to eq(2)
          expect(another_company.staffs_count).to eq(51)
          expect(another_company.staffs_male_count).to eq(30)
          expect(another_company.staffs_female_count).to eq(21)
        end

        it 'handles original category as empty/nil' do
          staff = Staff.create company: company, gender: nil

          company.set staffs_count: 5
          company.set staffs_male_count: 3
          company.set staffs_female_count: 2
          another_company.set staffs_count: 50
          another_company.set staffs_male_count: 30
          another_company.set staffs_female_count: 20

          staff.update_attributes company: another_company, gender: :female

          company.reload
          another_company.reload
          expect(company.staffs_count).to eq(4)
          expect(company.staffs_male_count).to eq(3)
          expect(company.staffs_female_count).to eq(2)
          expect(another_company.staffs_count).to eq(51)
          expect(another_company.staffs_male_count).to eq(30)
          expect(another_company.staffs_female_count).to eq(21)
        end

        it 'handles current category as empty/nil' do
          staff = Staff.create company: company, gender: :male

          company.set staffs_count: 5
          company.set staffs_male_count: 3
          company.set staffs_female_count: 2
          another_company.set staffs_count: 50
          another_company.set staffs_male_count: 30
          another_company.set staffs_female_count: 20

          staff.update_attributes company: another_company, gender: nil

          company.reload
          another_company.reload
          expect(company.staffs_count).to eq(4)
          expect(company.staffs_male_count).to eq(2)
          expect(company.staffs_female_count).to eq(2)
          expect(another_company.staffs_count).to eq(51)
          expect(another_company.staffs_male_count).to eq(30)
          expect(another_company.staffs_female_count).to eq(20)
        end
      end
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

    it 'handles original category as empty/nil' do
      staff = Staff.create company: company, gender: nil

      company.set staffs_count: 5
      company.set staffs_male_count: 3
      company.set staffs_female_count: 2

      staff.destroy

      company.reload
      expect(company.staffs_count).to eq(4)
      expect(company.staffs_male_count).to eq(3)
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

  context 'using relation as category' do
    let(:company) { CategoryAsRelation::Company.create }
    let(:west_city) { CategoryAsRelation::City.create region: :west }
    let(:east_city) { CategoryAsRelation::City.create region: :east }
    let(:user) { CategoryAsRelation::User.create company: company, city: west_city }

    before do
      user
    end

    context 'creation' do

      it 'increase counter when create resource with resource' do
        company.set users_count: 5
        company.set users_west_count: 3
        company.set users_east_count: 2

        CategoryAsRelation::User.create company: company, city: west_city

        company.reload
        expect(company.users_count).to eq(6)
        expect(company.users_west_count).to eq(4)
        expect(company.users_east_count).to eq(2)
      end

      it 'handles empty/nil value for relation' do
        company.set users_count: 5
        company.set users_west_count: 3
        company.set users_east_count: 2

        CategoryAsRelation::User.create company: company, city: nil

        company.reload
        expect(company.users_count).to eq(6)
        expect(company.users_west_count).to eq(3)
        expect(company.users_east_count).to eq(2)
      end

      it 'handles empty/nil value for cateogry form relation' do
        company.set users_count: 5
        company.set users_west_count: 3
        company.set users_east_count: 2

        no_region_city = CategoryAsRelation::City.create
        CategoryAsRelation::User.create company: company, city: no_region_city

        company.reload
        expect(company.users_count).to eq(6)
        expect(company.users_west_count).to eq(3)
        expect(company.users_east_count).to eq(2)
      end

    end

    context 'relation updated' do

      let(:another_company) { CategoryAsRelation::Company.create }

      context 'category has not been changed' do

        it 'decrease the counter of original relation and increase the counter of current relation' do
          company.set users_count: 5
          company.set users_west_count: 3
          company.set users_east_count: 2
          another_company.set users_count: 50
          another_company.set users_west_count: 30
          another_company.set users_east_count: 20

          user.update_attributes company: another_company

          company.reload
          another_company.reload
          expect(company.users_count).to eq(4)
          expect(company.users_west_count).to eq(2)
          expect(company.users_east_count).to eq(2)
          expect(another_company.users_count).to eq(51)
          expect(another_company.users_west_count).to eq(31)
          expect(another_company.users_east_count).to eq(20)
        end

      end

      context 'category relation has been changed' do

        it 'decrease the counter of original relation and increase the counter of current relation' do
          company.set users_count: 5
          company.set users_west_count: 3
          company.set users_east_count: 2
          another_company.set users_count: 50
          another_company.set users_west_count: 30
          another_company.set users_east_count: 20

          user.update_attributes company: another_company, city: east_city

          company.reload
          another_company.reload
          expect(company.users_count).to eq(4)
          expect(company.users_west_count).to eq(2)
          expect(company.users_east_count).to eq(2)
          expect(another_company.users_count).to eq(51)
          expect(another_company.users_west_count).to eq(30)
          expect(another_company.users_east_count).to eq(21)
        end
      end

    end

    context 'category has been updated' do

      it 'decrease the counter of original category and increase the counter of current category' do
        company.set users_count: 5
        company.set users_west_count: 3
        company.set users_east_count: 2

        user.update_attributes city: east_city

        company.reload
        expect(company.users_count).to eq(5)
        expect(company.users_west_count).to eq(2)
        expect(company.users_east_count).to eq(3)
      end
    end

    context 'destroy' do

      it 'decrease the counter of original category' do
        company.set users_count: 5
        company.set users_west_count: 3
        company.set users_east_count: 2

        user.destroy

        company.reload
        expect(company.users_count).to eq(4)
        expect(company.users_west_count).to eq(2)
        expect(company.users_east_count).to eq(2)
      end
    end
  end
end
