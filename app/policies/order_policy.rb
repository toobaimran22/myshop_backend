class OrderPolicy < ApplicationPolicy
  def index?
    user&.admin? || record.user == user
  end

  def show?
    user&.admin? || record.user == user
  end

  def create?
    user.present?
  end

  def approve?
    user&.admin?
  end

  def update?
    user&.admin?
  end

  def destroy?
    user&.admin?
  end
end 