{ by_days(entries).map( 
    (day,i) => 
      &lt;Day key={i} entries={day} 
         accounts={accounts} is_stock_account={is_stock_account} /> 
) }
