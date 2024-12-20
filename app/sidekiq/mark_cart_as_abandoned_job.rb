# frozen_string_literal: true

class MarkCartAsAbandonedJob
  include Sidekiq::Job

  def perform(*_args)
    abandoned_carts = Cart.active.where(['last_interaction_at <  ?', 3.hours.ago])
    abandoned_carts.each(&:mark_as_abandoned)

    removable_carts = Cart.abandoned.where(['last_interaction_at <  ?', 7.days.ago])
    removable_carts.each(&:remove_if_abandoned)
  end
end
