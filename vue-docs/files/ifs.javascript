{index === 0 && (
    <td className="day" rowSpan={size}>
        {moment(entry.postdate).format("DD")}
        <div className="weekday">{moment(entry.postdate).format("ddd")}</div>
    </td>
)}
