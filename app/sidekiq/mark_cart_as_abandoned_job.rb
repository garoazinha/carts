# frozen_string_literal: true

class MarkCartAsAbandonedJob
  include Sidekiq::Job

  def perform(*_args)
    abandoned_carts = Cart.where(['status = ? and last_interaction_at <  ?', 'active', 3.hours.ago])
    abandoned_carts.each(&:mark_as_abandoned)

    removable_carts = Cart.where(['status = ? and last_interaction_at <  ?', 'abandoned', 7.days.ago])
    removable_carts.each(&:remove_if_abandoned)
    # TODO; Impletemente um Job para gerenciar, marcar como abandonado. E remover carrinhos sem interação.
  end
end
