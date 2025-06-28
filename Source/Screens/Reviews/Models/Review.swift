/// Модель отзыва.
struct Review: Codable {
    
    /// Имя
    let firstName: String
    /// Фамилия
    let lastName: String
    /// Рейтинг
    let rating: Int
    /// Фото приложенные к отзыву
    let photoUrls: [String]
    /// Текст отзыва.
    let text: String
    /// Время создания отзыва.
    let created: String
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case rating
        case photoUrls = "photo_urls"
        case text
        case created
    }
    
}
