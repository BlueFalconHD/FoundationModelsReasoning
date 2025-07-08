//
//  PromptExamples.swift
//  FoundationModelsReasoning
//
//  Created by Hayes Dombroski on 7/5/25.
//

import Foundation

enum PromptExamples {
    static let reasoningExample = """
    ### Reasoning Example 1: Boarding a Flight 
    <Message role="user">
        <text>
            I leave the house at 3 p.m. The drive to the airport is 45 minutes. My flight boards 30 minutes before its 5 p.m. departure, and security typically takes 20 minutes. Will I board on time? Explain your reasoning.
        </text>
    </Message>
    <Message role="assistant">
        <ReasoningItem title="Determining Arrival Time At Airport">
            The user will leave the house at 3 p.m. Since the drive to the airport takes 45 minutes, they will arrive at the airport at 3:45 p.m. Self Check: 3:00 p.m. + 45 minutes = 3:45 p.m.
        </ReasoningItem>
        <ReasoningItem title="Calculating Security Wait Time">
            The user mentions that security typically takes 20 minutes. I have to be careful to ensure my calculations account for a max of 60 minutes per hour. Therefore, they will finish security at 4:05 p.m. Self Check: 3:45 p.m. + 20 minutes = 4:05 p.m.
        </ReasoningItem>
        <ReasoningItem title="Calculating Boarding Time">
            The flight boards 30 minutes before its 5 p.m. departure, which means boarding starts at 4:30 p.m. Since the user will finish security at 4:05 p.m., they will have time to board. Self Check: 4:05 p.m. + 25 minutes = 4:30 p.m.
        </ReasoningItem>
        <ReasoningItem title="Conclusion">
            The user will board the flight on time, as they will finish security at 4:05 p.m. and boarding starts at 4:30 p.m. Self Check: 4:05 p.m. < 4:30 p.m.
        </ReasoningItem>
    </Message>
    """
    
    static let responseExample = """
    ### Response Example 1: Boarding a Flight
    <Message role="user">
        <text>
            I leave the house at 3 p.m. The drive to the airport is 45 minutes. My flight boards 30 minutes before its 5 p.m. departure, and security typically takes 20 minutes. Will I board on time? Explain your reasoning.
        </text>
    </Message>
    <Message role="assistant">
        <ReasoningItem title="Determining Arrival Time At Airport">
            The user will leave the house at 3 p.m. Since the drive to the airport takes 45 minutes, they will arrive at the airport at 3:45 p.m. Self Check: 3:00 p.m. + 45 minutes = 3:45 p.m.
        </ReasoningItem>
        <ReasoningItem title="Calculating Security Wait Time">
            The user mentions that security typically takes 20 minutes. I have to be careful to ensure my calculations account for a max of 60 minutes per hour. Therefore, they will finish security at 4:05 p.m. Self Check: 3:45 p.m. + 20 minutes = 4:05 p.m.
        </ReasoningItem>
        <ReasoningItem title="Calculating Boarding Time">
            The flight boards 30 minutes before its 5 p.m. departure, which means boarding starts at 4:30 p.m. Since the user will finish security at 4:05 p.m., they will have time to board. Self Check: 4:05 p.m. + 25 minutes = 4:30 p.m.
        </ReasoningItem>
        <ReasoningItem title="Conclusion">
            The user will board the flight on time, as they will finish security at 4:05 p.m. and boarding starts at 4:30 p.m. Self Check: 4:05 p.m. < 4:30 p.m.
        </ReasoningItem>
        <text>
            Yes, you will board your flight on time. You will arrive at the airport at 3:45 p.m. (3:00 + 45 mins), finish security by 4:05 p.m. (3:45 + 20 mins), and boarding starts at 4:30 p.m. Since  4:05 is less than 4:30, you will have enough time to board your flight.
        </text>
    </Message>
    """
    
    static let additionalEvalExample = """
    ### Reasoning Example 1: Boarding a Flight 
    <Message role="user">
        <text>
            I leave the house at 3 p.m. The drive to the airport is 45 minutes. My flight boards 30 minutes before its 5 p.m. departure, and security typically takes 20 minutes. Will I board on time? Explain your reasoning.
        </text>
    </Message>
    
    Evaluation:
        additionalReasoningItemsNeededEstimate: 3
        numberOfReasoningItemsUntilNextEvaluation: 2
    
        3 steps are necessary to determine the arrival time at the airport, security wait time, and boarding time. The next evaluation will be after 2 more reasoning items to ensure the reasoning process is thorough and accurate.
    """
    
    static let redundancyEvalExample = """
    ### Reasoning Example 1: Boarding a Flight
    <Message role="user">
        <text>
            I leave the house at 3 p.m. The drive to the airport is 45 minutes. My flight boards 30 minutes before its 5 p.m. departure, and security typically takes 20 minutes. Will I board on time? Explain your reasoning.
        </text>
    </Message>
    <Message role="assistant">
        <ReasoningItem title="Determining Arrival Time At Airport">
            The user will leave the house at 3 p.m. Since the drive to the airport takes 45 minutes, they will arrive at the airport at 3:45 p.m. Self Check: 3:00 p.m. + 45 minutes = 3:45 p.m.
        </ReasoningItem>
        <ReasoningItem title="Calculating Security Wait Time">
            The user mentions that security typically takes 20 minutes. I have to be careful to ensure my calculations account for a max of 60 minutes per hour. Therefore, they will finish security at 4:05 p.m. Self Check: 3:45 p.m. + 20 minutes = 4:05 p.m.
        </ReasoningItem>
        <ReasoningItem title="Calculating Boarding Time">
            The flight boards 30 minutes before its 5 p.m. departure, which means boarding starts at 4:30 p.m. Since the user will finish security at 4:05 p.m., they will have time to board. Self Check: 4:05 p.m. + 25 minutes = 4:30 p.m.
        </ReasoningItem>
        <ReasoningItem title="Boarding Time Calculation">
            Boarding starts at 4:30 and since the user will finish security at 4:05, they will have time to board. Self Check: 4:05 p.m. + 25 minutes = 4:30 p.m.
        </ReasoningItem>
    </Message>
    
    Redundancy Evaluation:
        The most recent reasoning item is redundant because it repeats the same calculation as the previous item about boarding time. It does not add any new information or insight to the reasoning process.
    """
}
            
