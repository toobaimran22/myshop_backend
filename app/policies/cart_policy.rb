class CartPolicy < ApplicationPolicy
  def show?
    user&.admin? || user == record.user
  end

  def update?
    user&.admin? || user == record.user
  end

  def destroy?
    user&.admin? || user == record.user
  end

  def add_item?
    user&.admin? || user == record.user
  end
end 