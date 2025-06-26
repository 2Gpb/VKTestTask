/// Модель отзыва.
struct Review: Codable {
    let firstName: String
    let lastName: String
    let rating: Int
    
    /// Текст отзыва.
    let text: String
    /// Время создания отзыва.
    let created: String
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case rating
        case text
        case created
    }
}
