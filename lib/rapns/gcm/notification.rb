module Rapns
  module Gcm
    class Notification < Rapns::Notification
      # TODO: Dump using multi json.
      serialize :registration_ids

      validates :registration_ids, :presence => true
      validates_with Rapns::Gcm::ExpiryCollapseKeyMutualInclusionValidator
      validates_with Rapns::Gcm::PayloadDataSizeValidator
      validates_with Rapns::Gcm::RegistrationIdsCountValidator

      validates_uniqueness_of :registration_ids, :scope => :job_id, :if => Proc.new { |n| !n.job.nil? }

      def registration_ids=(ids)
        ids = [ids] if ids && !ids.is_a?(Array)
        super
      end

      def as_json
        json = {
          'registration_ids' => registration_ids,
          'delay_while_idle' => delay_while_idle,
          'data' => data
        }

        if collapse_key
          json['collapse_key'] = collapse_key
        end

        if expiry
          json['time_to_live'] = expiry
        end

        json
      end

      def payload_data_size
        multi_json_dump(as_json['data']).bytesize
      end
    end
  end
end
