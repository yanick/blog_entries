export default {
  props:      [ 'month', 'start_balance', 'entries', 
                'accounts', 'is_stock_account' ],
  components: { MonthSummary, Money, Day },
  filters:    { named_month },
  computed:   { days },
};
