{index === 0 && (
    &lt;td className="day" rowSpan={size}>
        {moment(entry.postdate).format("DD")}
        &lt;div className="weekday">{moment(entry.postdate).format("ddd")}&lt;/div>
    &lt;/td>
)}
