import {useState} from 'react'

export const App = () => {
    const [count, setCount] = useState(0)

    return (
        <div>
            <p>Hello Bun!</p>
            <p>
                <button type='button' onClick={() => setCount((count) => count + 1)}>
                    count is: {count}
                </button>
            </p>
        </div>
    )
}